class Api::V1::Accounts::MailerSettingsController < Api::V1::Accounts::BaseController
  BOOLEAN_OVERRIDES = %i[enable_starttls_auto ssl].freeze

  before_action :check_admin_authorization?

  def show
    @settings = MailerSettingsService.current_settings
  end

  def update
    MailerSettingsService.update!(mailer_settings_params)
    @settings = MailerSettingsService.current_settings
  end

  def reload
    MailerSettingsService.apply!
    ReloadMailerSettingsJob.perform_later
    head :ok
  end

  def test
    to = params[:to].presence || Current.user.email
    MailerSettingsService.deliver_test_email(to: to, overrides: test_overrides)
    render json: { to: to }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def mailer_settings_params
    params.permit(*MailerSettingsService::CONFIG_KEYS)
  end

  def test_overrides
    return {} unless params[:settings]

    overrides = params[:settings].permit(
      :address, :port, :user_name, :password, :authentication, :domain, :enable_starttls_auto, :ssl, :from
    ).to_h.symbolize_keys
    normalize_overrides(overrides)
  end

  def normalize_overrides(overrides)
    # Stray whitespace from copy-pasted credentials silently breaks DNS
    # resolution -- trim before it ever reaches the SMTP client.
    overrides.transform_values! { |value| value.is_a?(String) ? value.strip : value }
    overrides[:port] = overrides[:port].to_i if overrides[:port].present?
    overrides[:authentication] = overrides[:authentication].to_sym if overrides[:authentication].present?
    BOOLEAN_OVERRIDES.each { |key| overrides[key] = ActiveModel::Type::Boolean.new.cast(overrides[key]) if overrides.key?(key) }
    overrides
  end
end
