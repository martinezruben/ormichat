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

  desc 'Regenera los embeddings de Captain (correr tras cambiar el modelo de embeddings). Se encolan en Sidekiq.'
  task reembed: :environment do
    sources = {
      ArticleEmbedding => :term,
      Captain::AssistantResponse => ->(record) { "#{record.question}: #{record.answer}" },
      Captain::FaqSuggestion => ->(record) { "#{record.question}: #{record.answer}" }
    }

    sources.each do |model, content|
      count = 0
      model.find_each do |record|
        next if model == Captain::FaqSuggestion && !record.open?

        text = content.respond_to?(:call) ? content.call(record) : record.public_send(content)
        Captain::Llm::UpdateEmbeddingJob.perform_later(record, text)
        count += 1
      end
      puts "✔ #{model.name}: #{count} encolados"
    end
  end

  desc 'Verifica que Captain pueda hablar con el modelo de chat y el de embeddings configurados (Super Admin > Settings).'
  task ai_check: :environment do
    model = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL')&.value.presence || Llm::Config::DEFAULT_MODEL
    chat = Llm::Config.chat_credentials

    begin
      reply = Llm::Config.with_api_key(chat[:api_key], api_base: chat[:api_base]) do |context|
        context.chat(model: model, provider: :openai, assume_model_exists: true).ask('Responde solo con la palabra: ok').content
      end
      puts "✔ Chat (#{model} @ #{chat[:api_base] || 'api.openai.com'}): #{reply.to_s.strip.truncate(60)}"
    rescue StandardError => e
      abort "✘ Chat (#{model}): #{e.class}: #{e.message}"
    end

    begin
      vector = Captain::Llm::EmbeddingService.new.get_embedding('prueba de conexión')
      embedding = Llm::Config.embedding_credentials
      puts "✔ Embeddings (#{Captain::Llm::EmbeddingService.embedding_model} @ #{embedding[:api_base] || 'api.openai.com'}): " \
           "#{vector.length} dimensiones"
    rescue StandardError => e
      abort "✘ Embeddings: #{e.class}: #{e.message}"
    end
  end
end
# rubocop:enable Metrics/BlockLength
