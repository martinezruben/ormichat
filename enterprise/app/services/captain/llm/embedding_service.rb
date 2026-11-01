class Captain::Llm::EmbeddingService
  include Integrations::LlmInstrumentation

  class EmbeddingsError < StandardError; end

  def initialize(account_id: nil)
    Llm::Config.initialize!
    @account_id = account_id
    @embedding_model = self.class.embedding_model
  end

  def self.embedding_model
    InstallationConfig.find_by(name: 'CAPTAIN_EMBEDDING_MODEL')&.value.presence || LlmConstants::DEFAULT_EMBEDDING_MODEL
  end

  def get_embedding(content, model: @embedding_model)
    return [] if content.blank?

    instrument_embedding_call(instrumentation_params(content, model)) do
      embed(content, model)
    end
  rescue RubyLLM::Error => e
    Rails.logger.error "Embedding API Error: #{e.message}"
    raise EmbeddingsError, "Failed to create an embedding: #{e.message}"
  end

  private

  # Siempre protocolo OpenAI-compatible (OpenAI, Ollama, Gemini, OpenRouter, LiteLLM...), con el endpoint propio
  # de embeddings si existe. Se pide EMBEDDING_DIMENSIONS para que modelos con tamaño configurable
  # (p. ej. text-embedding-3-*) encajen en las columnas vector(768).
  def embed(content, model)
    credentials = Llm::Config.embedding_credentials
    vectors = Llm::Config.with_api_key(credentials[:api_key], api_base: credentials[:api_base]) do |context|
      context.embed(content, model: model, provider: :openai, assume_model_exists: true,
                             dimensions: LlmConstants::EMBEDDING_DIMENSIONS).vectors
    end
    return vectors if vectors.length == LlmConstants::EMBEDDING_DIMENSIONS

    raise EmbeddingsError, "El modelo #{model} devolvió #{vectors.length} dimensiones; se esperaban #{LlmConstants::EMBEDDING_DIMENSIONS}"
  end

  def instrumentation_params(content, model)
    {
      span_name: 'llm.captain.embedding',
      model: model,
      input: content,
      feature_name: 'embedding',
      account_id: @account_id
    }
  end
end
