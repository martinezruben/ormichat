require 'rails_helper'

RSpec.describe Products::ChatFormatter do
  let(:account) { Account.create!(name: 'Farmacia Test') }
  let(:product) do
    account.products.create!(
      name: 'Ibuprofeno 400 mg', sku: 'I-1', category: 'Analgésicos', brand: 'Genérico',
      description: 'Tabletas antiinflamatorias.', ai_description: 'Recomendar para dolor muscular.',
      image_url: '/product-samples/i.svg',
      variants_attributes: [
        { name: 'Caja x 10', sku: 'I-1-A', price: 12, stock: 80 },
        { name: 'Caja x 20', sku: 'I-1-B', price: 21.5, stock: 3 },
        { name: 'Caja x 30', sku: 'I-1-C', price: 30, stock: 0 }
      ]
    )
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('FRONTEND_URL', '').and_return('https://app.test')
  end

  it 'renders the details, guidance, photo and each variety with price and stock' do
    text = described_class.format([product])

    expect(text).to include('Product: Ibuprofeno 400 mg (SKU I-1)', 'Brand: Genérico', 'Category: Analgésicos')
    expect(text).to include('When to recommend and guidance: Recomendar para dolor muscular.')
    expect(text).to include('Photo: https://app.test/product-samples/i.svg')
    expect(text).to include('- Caja x 10: 12.00 DOP, in stock, 80 units')
    expect(text).to include('- Caja x 20: 21.50 DOP, low stock, 3 units')
    expect(text).to include('- Caja x 30: 30.00 DOP, out of stock')
  end

  it 'leaves out inactive varieties' do
    product.variants.find_by(sku: 'I-1-A').update!(active: false)

    expect(described_class.format([product])).not_to include('Caja x 10')
  end

  it 'prefixes the context for the assistant with the safety instructions' do
    text = described_class.assistant_context([product])

    expect(text).to start_with(described_class::INSTRUCTIONS)
    expect(text).to include('Product: Ibuprofeno 400 mg')
  end
end
