# Installation-wide SMTP / outgoing-mail configuration, editable from the
# dashboard (Settings > Security) instead of only via ENV vars.
#
# Storage: InstallationConfig (same mechanism as INSTALLATION_NAME etc.),
# read through GlobalConfigService so ENV vars remain a working fallback
# for installs that configure it the old way and never touch the UI.
#
# On purpose, NOTHING here is applied automatically. Saving only persists
# the values — ActionMailer keeps using whatever was last applied until
# `MailerSettingsService.apply!` is explicitly called (the "Reload configuration"
# button), since the actual delivery happens in a separate Sidekiq process
# that a plain settings save can't reach.
class MailerSettingsService
  CONFIG_KEYS = %w[
    SMTP_ADDRESS
    SMTP_PORT
    SMTP_USERNAME
    SMTP_PASSWORD
    SMTP_AUTHENTICATION
    SMTP_DOMAIN
    SMTP_ENABLE_STARTTLS_AUTO
    SMTP_SSL
    MAILER_SENDER_EMAIL
  ].freeze

  # Keys sent to the frontend as-is (everything except the password, which
  # is write-only: the show endpoint only reports whether one is set).
  PUBLIC_KEYS = (CONFIG_KEYS - ['SMTP_PASSWORD']).freeze

  class << self
    def current_settings
      PUBLIC_KEYS.index_with { |key| GlobalConfigService.load(key, nil) }
                 .merge('SMTP_PASSWORD_SET' => stored_value('SMTP_PASSWORD').present?)
    end

    def update!(params)
      CONFIG_KEYS.each do |key|
        next unless params.key?(key)

        value = params[key]
        # Stray leading/trailing whitespace from copy-pasted credentials
        # (e.g. a space before the host) silently breaks DNS resolution --
        # trim before it ever reaches ActionMailer.
        value = value.strip if value.is_a?(String)
        # Blank password means "leave the existing one alone" -- there's no
        # way to re-enter it blindly since it's never sent back to the form.
        next if key == 'SMTP_PASSWORD' && value.blank?

        InstallationConfig.find_or_initialize_by(name: key).update!(value: value, locked: false)
      end
      GlobalConfig.clear_cache
    end

    # Effective SMTP_ADDRESS check, replacing the ENV-only version mailers
    # used to call directly -- this is the actual on/off switch for every
    # mailer's smtp_config_set_or_development? guard.
    def configured?
      GlobalConfigService.load('SMTP_ADDRESS', nil).present?
    end

    # Applies the currently-stored settings to the running process: the
    # ActionMailer delivery method/settings and the default From address.
    # Call this from both the web process (controller) and a Sidekiq job,
    # since they're separate Ruby processes that don't share memory.
    def apply!
      if configured?
        ActionMailer::Base.delivery_method = :smtp
        ActionMailer::Base.smtp_settings = build_smtp_settings
      else
        ActionMailer::Base.delivery_method = :sendmail
      end

      from = GlobalConfigService.load('MAILER_SENDER_EMAIL', nil)
      if from.present?
        ApplicationMailer.default(from: from)
        ConversationReplyMailer.default(from: from)
      end

      true
    end

    # One-off delivery bypassing ActionMailer's global state entirely, so
    # testing not-yet-saved form values can't affect real mail delivery.
    def deliver_test_email(to:, overrides: {})
      settings = build_smtp_settings.merge(overrides.compact)
      from = overrides[:from].presence || GlobalConfigService.load('MAILER_SENDER_EMAIL', nil).presence ||
             'Ormichat <no-reply@localhost>'

      Mail.deliver do
        delivery_method :smtp, settings
        to to
        from from
        subject 'Ormichat: correo de prueba'
        body "Si recibiste este correo, la configuración de SMTP funciona correctamente.\n\nEnviado #{Time.current}."
      end
    end

    private

    def stored_value(key)
      InstallationConfig.find_by(name: key)&.value
    end

    def build_smtp_settings
      settings = {
        address: GlobalConfigService.load('SMTP_ADDRESS', 'localhost'),
        port: GlobalConfigService.load('SMTP_PORT', 587).to_i
      }

      authentication = GlobalConfigService.load('SMTP_AUTHENTICATION', nil)
      settings[:authentication] = authentication.to_sym if authentication.present?

      domain = GlobalConfigService.load('SMTP_DOMAIN', nil)
      settings[:domain] = domain if domain.present?

      settings[:user_name] = GlobalConfigService.load('SMTP_USERNAME', nil)
      settings[:password] = GlobalConfigService.load('SMTP_PASSWORD', nil)

      settings[:enable_starttls_auto] = ActiveModel::Type::Boolean.new.cast(
        GlobalConfigService.load('SMTP_ENABLE_STARTTLS_AUTO', true)
      )

      ssl = GlobalConfigService.load('SMTP_SSL', nil)
      settings[:ssl] = ActiveModel::Type::Boolean.new.cast(ssl) if ssl.present?

      settings
    end
  end
end
