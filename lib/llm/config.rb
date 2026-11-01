require 'ruby_llm'

module Llm::Config
  DEFAULT_MODEL = 'gpt-4.1-mini'.freeze

  class << self
    def initialized?
      @initialized ||= false
    end

    def initialize!
      return if @initialized

      configure_ruby_llm
      @initialized = true
    end

    def reset!
      @initialized = false
    end

    def with_api_key(api_key, api_base: nil)
      initialize!
      context = RubyLLM.context do |config|
        config.openai_api_key = api_key
        config.openai_api_base = api_base
      end

      yield context
    end

    def chat_credentials
      { api_key: system_api_key, api_base: normalize_endpoint(openai_endpoint) }
    end

    # Los embeddings pueden ir a otro proveedor que el chat (p. ej. chat remoto y embeddings locales).
    # Si no hay endpoint/clave propios, usan los del chat.
    def embedding_credentials
      {
        api_key: installation_value('CAPTAIN_EMBEDDING_API_KEY') || system_api_key,
        api_base: normalize_endpoint(installation_value('CAPTAIN_EMBEDDING_ENDPOINT') || openai_endpoint)
      }
    end

    private

    def installation_value(name)
      InstallationConfig.find_by(name: name)&.value.presence
    end

    def configure_ruby_llm
      RubyLLM.configure do |config|
        config.openai_api_key = system_api_key if system_api_key.present?
        config.openai_api_base = normalize_endpoint(openai_endpoint) if openai_endpoint.present?
        config.openai_protocol = LlmConstants::OPENAI_COMPATIBLE_PROTOCOL
        config.openai_use_system_role = true
        config.model_registry_file = Rails.root.join('config/llm_models.json').to_s
        config.logger = Rails.logger
      end
    end

    def system_api_key
      InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value
    end

    def openai_endpoint
      installation_value('CAPTAIN_OPEN_AI_ENDPOINT')
    end

    # ruby_llm's OpenAI provider expects `openai_api_base` to already include
    # the `/v1` suffix (its own default is 'https://api.openai.com/v1').
    def normalize_endpoint(endpoint)
      return if endpoint.blank?

      base = endpoint.chomp('/')
      base.end_with?('/v1') ? base : "#{base}/v1"
    end
  end
end
