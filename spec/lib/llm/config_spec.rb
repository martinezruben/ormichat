require 'rails_helper'

RSpec.describe Llm::Config do
  def configure_llm(values)
    values.each { |name, value| InstallationConfig.find_or_initialize_by(name: name).update!(value: value) }
  end

  describe '.chat_credentials' do
    it 'adds /v1 to the configured endpoint' do
      configure_llm('CAPTAIN_OPEN_AI_API_KEY' => 'chat-key', 'CAPTAIN_OPEN_AI_ENDPOINT' => 'http://ollama.test:11434')

      expect(described_class.chat_credentials).to eq(api_key: 'chat-key', api_base: 'http://ollama.test:11434/v1')
    end

    it 'does not duplicate /v1 nor keep a trailing slash' do
      configure_llm('CAPTAIN_OPEN_AI_API_KEY' => 'k', 'CAPTAIN_OPEN_AI_ENDPOINT' => 'http://llm.test/v1/')

      expect(described_class.chat_credentials[:api_base]).to eq('http://llm.test/v1')
    end

    it 'leaves api_base empty so the provider default is used' do
      configure_llm('CAPTAIN_OPEN_AI_API_KEY' => 'k', 'CAPTAIN_OPEN_AI_ENDPOINT' => '')

      expect(described_class.chat_credentials[:api_base]).to be_nil
    end
  end

  describe '.embedding_credentials' do
    it 'falls back to the chat provider when there is no embedding endpoint or key' do
      configure_llm('CAPTAIN_OPEN_AI_API_KEY' => 'chat-key', 'CAPTAIN_OPEN_AI_ENDPOINT' => 'http://chat.test',
                    'CAPTAIN_EMBEDDING_API_KEY' => '', 'CAPTAIN_EMBEDDING_ENDPOINT' => '')

      expect(described_class.embedding_credentials).to eq(api_key: 'chat-key', api_base: 'http://chat.test/v1')
    end

    it 'uses its own endpoint and key when configured (remote chat, local embeddings)' do
      configure_llm('CAPTAIN_OPEN_AI_API_KEY' => 'chat-key', 'CAPTAIN_OPEN_AI_ENDPOINT' => 'https://remote.test',
                    'CAPTAIN_EMBEDDING_API_KEY' => 'embed-key', 'CAPTAIN_EMBEDDING_ENDPOINT' => 'http://localhost:11434')

      expect(described_class.embedding_credentials).to eq(api_key: 'embed-key', api_base: 'http://localhost:11434/v1')
    end
  end

  describe '.build_chat' do
    before { described_class.initialize! }

    it 'builds a chat for a model that is in the registry' do
      expect(described_class.build_chat(RubyLLM, 'gpt-4.1-mini').model.id).to eq('gpt-4.1-mini')
    end

    it 'treats a self-hosted model missing from the registry as OpenAI-compatible' do
      chat = described_class.build_chat(RubyLLM, 'qwen2.5:7b-instruct')

      expect(chat.model.id).to eq('qwen2.5:7b-instruct')
    end
  end
end
