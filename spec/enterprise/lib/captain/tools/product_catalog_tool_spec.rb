require 'rails_helper'

RSpec.describe Captain::Tools::ProductCatalogTool do
  let(:account) { Account.create!(name: 'Farmacia Test') }
  let(:other_account) { Account.create!(name: 'Otra Farmacia') }
  let(:assistant) { Captain::Assistant.create!(account: account, name: 'Asistente', description: 'Prueba') }
  let(:tool) { described_class.new(assistant) }

  before do
    account.products.create!(
      name: 'Protector solar FPS 50', sku: 'S-1', category: 'Cuidado de la piel',
      ai_description: 'Recomendar cuando el cliente vaya a la playa o al sol.',
      variants_attributes: [{ name: 'Tubo 60 ml', sku: 'S-1-A', price: 78, stock: 28 }]
    )
    other_account.products.create!(
      name: 'Protector ajeno', sku: 'S-2', category: 'Cuidado de la piel',
      variants_attributes: [{ name: 'Tubo', sku: 'S-2-A', price: 1, stock: 1 }]
    )
  end

  it 'declares its arguments for the model' do
    schema = tool.parameters_schema

    expect(schema['properties'].keys).to match_array(%w[query category])
    expect(schema['required']).to eq(['query'])
  end

  it 'is available to the assistant as a built-in tool' do
    expect(Captain::Assistant.built_in_tool_ids).to include('product_catalog')
    expect(assistant.send(:agent_tools).map { |agent_tool| agent_tool.class.name }).to include('Captain::Tools::ProductCatalogTool')
  end

  it 'answers with price, stock and guidance for what the customer needs' do
    result = tool.perform(nil, query: 'voy a la playa')

    expect(result).to include('Protector solar FPS 50', 'Tubo 60 ml: 78.00 DOP, in stock, 28 units', 'playa')
    expect(result).to include('Do not give medical advice')
  end

  it 'only looks inside the catalog of the assistant account' do
    expect(tool.perform(nil, query: 'protector')).not_to include('Protector ajeno')
  end

  it 'says so when nothing matches' do
    expect(tool.perform(nil, query: 'xyzabc')).to eq('No products found for: xyzabc')
  end

  it 'also works for the Captain V1 search service' do
    result = Captain::Tools::SearchProductsService.new(assistant, user: nil).execute(query: 'protector')

    expect(result).to include('Protector solar FPS 50')
    expect(result).not_to include('Protector ajeno')
  end
end
