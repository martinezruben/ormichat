# frozen_string_literal: true

module LlmConstants
  DEFAULT_MODEL = 'gpt-4.1'
  DEFAULT_EMBEDDING_MODEL = 'text-embedding-3-small'
  # Debe coincidir con las columnas vector(768) de la base de datos.
  EMBEDDING_DIMENSIONS = 768
  PDF_PROCESSING_MODEL = 'gpt-4.1-mini'

  OPENAI_API_ENDPOINT = 'https://api.openai.com'
  # ruby_llm 2.x usa por defecto la Responses API de OpenAI; los servidores compatibles (Ollama, vLLM, LiteLLM,
  # OpenRouter...) hablan Chat Completions.
  OPENAI_COMPATIBLE_PROTOCOL = :chat_completions

  PROVIDER_PREFIXES = {
    'openai' => %w[gpt- o1 o3 o4 text-embedding- whisper- tts-],
    'anthropic' => %w[claude-],
    'google' => %w[gemini-],
    'mistral' => %w[mistral- codestral-],
    'deepseek' => %w[deepseek-]
  }.freeze
end
