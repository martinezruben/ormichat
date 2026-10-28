# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :ormichat do
  desc 'Apply Ormichat branding, Enterprise plan and (optionally) Captain on Ollama to a fresh install. Safe to re-run.'
  task setup: :environment do
    frontend_url = ENV.fetch('FRONTEND_URL')

    {
      'INSTALLATION_NAME' => 'Ormichat',
      'BRAND_NAME' => 'Ormichat',
      'BRAND_URL' => frontend_url,
      'WIDGET_BRAND_URL' => frontend_url,
      'LOGO' => '/brand-assets/logo.svg',
      'LOGO_DARK' => '/brand-assets/logo_dark.svg',
      'LOGO_THUMBNAIL' => '/brand-assets/logo_thumbnail.svg',
      'INSTALLATION_PRICING_PLAN' => 'enterprise'
    }.each { |name, value| InstallationConfig.find_by!(name: name).update!(value: value) }
    puts '✔ Branding Ormichat y plan enterprise'

    premium = SuperAdmin::AccountFeaturesHelper.account_premium_features
    defaults = InstallationConfig.find_by!(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
    defaults.update!(value: defaults.value.map { |f| premium.include?(f['name']) ? f.merge('enabled' => true) : f })
    Account.find_each do |account|
      account.enable_features!(*premium)
      account.update!(locale: ENV.fetch('DEFAULT_LOCALE', 'es'))
    end
    puts "✔ Features premium activadas en #{Account.count} cuenta(s) y en los defaults de cuentas nuevas"

    if ENV['CAPTAIN_ENDPOINT'].present?
      {
        'CAPTAIN_OPEN_AI_ENDPOINT' => ENV.fetch('CAPTAIN_ENDPOINT'),
        'CAPTAIN_OPEN_AI_API_KEY' => 'ollama-local',
        'CAPTAIN_OPEN_AI_MODEL' => ENV.fetch('CAPTAIN_MODEL', 'qwen2.5:7b-instruct'),
        'CAPTAIN_EMBEDDING_MODEL' => ENV.fetch('CAPTAIN_EMBEDDING_MODEL', 'nomic-embed-text')
      }.each { |name, value| InstallationConfig.find_by!(name: name).update!(value: value) }
      puts "✔ Captain → #{ENV.fetch('CAPTAIN_ENDPOINT')}"
    else
      puts '• Captain sin cambios (pasar CAPTAIN_ENDPOINT=http://<gateway-docker>:11434 para configurarlo)'
    end

    GlobalConfig.clear_cache
    puts 'Listo. Reiniciar rails y sidekiq para que tomen la configuración.'
  end
end
# rubocop:enable Metrics/BlockLength
