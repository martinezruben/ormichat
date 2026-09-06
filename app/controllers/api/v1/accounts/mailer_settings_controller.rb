class Api::V1::Accounts::MailerSettingsController < Api::V1::Accounts::BaseController
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
    # Stray whitespace from copy-pasted credentials silently breaks DNS
    # resolution -- trim before it ever reaches the SMTP client.
    overrides.each { |key, value| overrides[key] = value.strip if value.is_a?(String) }
    overrides[:port] = overrides[:port].to_i if overrides[:port].present?
    overrides[:authentication] = overrides[:authentication].to_sym if overrides[:authentication].present?
    if overrides.key?(:enable_starttls_auto)
      overrides[:enable_starttls_auto] = ActiveModel::Type::Boolean.new.cast(overrides[:enable_starttls_auto])
    end
    overrides[:ssl] = ActiveModel::Type::Boolean.new.cast(overrides[:ssl]) if overrides.key?(:ssl)
    overrides
  end
end
