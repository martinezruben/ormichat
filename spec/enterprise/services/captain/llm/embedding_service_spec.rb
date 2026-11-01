require 'rails_helper'

RSpec.describe Captain::Llm::EmbeddingService do
  let(:endpoint) { 'http://embeddings.test' }
  let(:dimensions) { LlmConstants::EMBEDDING_DIMENSIONS }

  before do
    {
      'CAPTAIN_OPEN_AI_API_KEY' => 'chat-key', 'CAPTAIN_OPEN_AI_ENDPOINT' => 'http://chat.test',
      'CAPTAIN_EMBEDDING_API_KEY' => 'embed-key', 'CAPTAIN_EMBEDDING_ENDPOINT' => endpoint,
      'CAPTAIN_EMBEDDING_MODEL' => 'nomic-embed-text'
    }.each { |name, value| InstallationConfig.find_or_initialize_by(name: name).update!(value: value) }
  end

  def stub_embeddings(length)
    stub_request(:post, "#{endpoint}/v1/embeddings")
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                 body: { data: [{ embedding: Array.new(length, 0.1) }], usage: { prompt_tokens: 3 } }.to_json)
  end

  it 'sends the request to the embedding endpoint with its own key, model and 768 dimensions' do
    request = stub_embeddings(dimensions)

    vector = described_class.new.get_embedding('hola')

    expect(vector.length).to eq(dimensions)
    expect(request.with(headers: { 'Authorization' => 'Bearer embed-key' },
                        body: hash_including('model' => 'nomic-embed-text', 'dimensions' => dimensions))).to have_been_requested
  end

  it 'raises a clear error when the model returns another size' do
    stub_embeddings(1536)

    expect { described_class.new.get_embedding('hola') }
      .to raise_error(described_class::EmbeddingsError, /devolvió 1536 dimensiones; se esperaban 768/)
  end

  it 'returns an empty vector for blank content without calling the provider' do
    expect(described_class.new.get_embedding('')).to eq([])
  end
end
