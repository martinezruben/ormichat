require 'rails_helper'

RSpec.describe Concerns::Toolable do
  let(:account) { Account.create!(name: 'Farmacia Test') }
  let(:assistant) { Captain::Assistant.create!(account: account, name: 'Asistente', description: 'Prueba') }
  let(:custom_tool) do
    Captain::CustomTool.create!(
      account: account, slug: 'consulta_stock', title: 'Stock', description: 'Consulta el stock por SKU', http_method: 'GET',
      endpoint_url: 'https://example.com/stock?sku={{ sku }}', auth_type: 'none', enabled: true,
      param_schema: [{ 'name' => 'sku', 'type' => 'string', 'description' => 'SKU del producto', 'required' => true },
                     { 'name' => 'sucursal', 'type' => 'string', 'description' => 'Sucursal', 'required' => false }]
    )
  end

  [Captain::Tools::HttpTool, Captain::Tools::CustomHttpTool].each do |base_class|
    describe "#tool with #{base_class.name.demodulize}" do
      subject(:tool) { custom_tool.tool(assistant, base_class: base_class) }

      it 'is named after the slug' do
        expect(tool.name).to eq('consulta_stock')
      end

      it 'exposes the declared parameters to the model, with their required flag' do
        schema = tool.parameters_schema

        expect(schema['properties'].keys).to contain_exactly('sku', 'sucursal')
        expect(schema['properties']['sku']['description']).to eq('SKU del producto')
        expect(schema['required']).to eq(['sku'])
      end
    end
  end

  it 'passes the arguments chosen by the model to the HTTP call and returns its response' do
    tool = custom_tool.tool(assistant, base_class: Captain::Tools::CustomHttpTool)
    result = Struct.new(:tempfile).new(StringIO.new('12 unidades'))
    allow(SafeFetch).to receive(:fetch).and_yield(result)

    expect(tool.call(sku: '123')).to include('12 unidades')
    expect(SafeFetch).to have_received(:fetch).with('https://example.com/stock?sku=123', hash_including(method: :get))
  end
end
