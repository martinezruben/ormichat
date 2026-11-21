require 'rails_helper'

RSpec.describe Product do
  let(:account) { Account.create!(name: 'Farmacia Test') }
  let(:other_account) { Account.create!(name: 'Otra Farmacia') }

  let!(:paracetamol) do
    account.products.create!(
      name: 'Paracetamol 500 mg', sku: 'P-1', category: 'Analgésicos', brand: 'Genérico',
      description: 'Tabletas para el dolor y la fiebre.',
      ai_description: 'Recomendar cuando el cliente tenga dolor de cabeza o fiebre.',
      variants_attributes: [
        { name: 'Caja x 10', sku: 'P-1-A', price: 8.5, stock: 20 },
        { name: 'Caja x 20', sku: 'P-1-B', price: 15, stock: 0 }
      ]
    )
  end
  let!(:jarabe) do
    account.products.create!(
      name: 'Jarabe para la tos infantil', sku: 'J-1', category: 'Resfrío y tos',
      ai_description: 'Recomendar cuando un niño tenga tos seca.',
      variants_attributes: [{ name: 'Frasco 100 ml', sku: 'J-1-A', price: 32, stock: 3 }]
    )
  end
  let!(:agotado) do
    account.products.create!(
      name: 'Alcohol en gel', sku: 'A-1', category: 'Higiene',
      variants_attributes: [{ name: 'Botella 1 L', sku: 'A-1-A', price: 41, stock: 0 }]
    )
  end
  let!(:inactive) do
    account.products.create!(
      name: 'Producto retirado', sku: 'R-1', category: 'Higiene', active: false,
      variants_attributes: [{ name: 'Unidad', sku: 'R-1-A', price: 1, stock: 5 }]
    )
  end

  describe 'validations' do
    it 'requires name, sku and category' do
      product = account.products.new

      expect(product).not_to be_valid
      expect(product.errors.attribute_names).to include(:name, :sku, :category)
    end

    it 'keeps the sku unique per account only' do
      expect(account.products.new(name: 'Copia', sku: 'P-1', category: 'X')).not_to be_valid
      expect(other_account.products.new(name: 'Copia', sku: 'P-1', category: 'X')).to be_valid
    end

    it 'rejects negative prices and stock' do
      variant = paracetamol.variants.new(name: 'Mala', sku: 'P-1-C', price: -1, stock: -2)

      expect(variant).not_to be_valid
      expect(variant.errors.attribute_names).to include(:price, :stock)
    end
  end

  describe '#availability' do
    it 'reports in stock, low stock and out of stock' do
      expect(paracetamol.variants.find_by(sku: 'P-1-A').availability).to eq('in_stock')
      expect(jarabe.variants.first.availability).to eq('low_stock')
      expect(agotado.variants.first.availability).to eq('out_of_stock')
    end
  end

  describe '#total_stock' do
    it 'adds the stock of the active varieties' do
      expect(paracetamol.reload.total_stock).to eq(20)
    end
  end

  describe '.filter_by' do
    it 'hides inactive products unless asked' do
      expect(described_class.filter_by({})).not_to include(inactive)
      expect(described_class.filter_by(include_inactive: true)).to include(inactive)
    end

    it 'searches the name, description and guidance text' do
      expect(described_class.filter_by(q: 'paracetamol')).to contain_exactly(paracetamol)
      expect(described_class.filter_by(q: 'fiebre')).to contain_exactly(paracetamol)
    end

    it 'filters by category and stock' do
      expect(described_class.filter_by(category: 'Higiene')).to contain_exactly(agotado)
      expect(described_class.filter_by(in_stock: true)).to contain_exactly(paracetamol, jarabe)
    end
  end

  describe '.lookup' do
    it 'finds a product by the need the customer describes' do
      expect(described_class.lookup(query: 'me duele la cabeza')).to contain_exactly(paracetamol)
    end

    it 'matches whole words so short terms do not hit unrelated products' do
      expect(described_class.lookup(query: 'tos')).to contain_exactly(jarabe)
    end

    it 'ignores filler words' do
      expect(described_class.lookup(query: 'quiero algo para la tos de mi hijo')).to contain_exactly(jarabe)
    end

    it 'narrows by category and skips inactive products' do
      expect(described_class.lookup(query: 'retirado')).to be_empty
      expect(described_class.lookup(query: 'tos', category: 'Higiene')).to be_empty
    end

    it 'returns nothing for an unknown product' do
      expect(described_class.lookup(query: 'xyzabc')).to be_empty
    end
  end

  describe '#photo_url' do
    it 'returns an absolute URL for relative image paths' do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('FRONTEND_URL', '').and_return('https://app.test')
      paracetamol.image_url = '/product-samples/p.svg'

      expect(paracetamol.photo_url).to eq('https://app.test/product-samples/p.svg')
    end

    it 'keeps external URLs untouched' do
      paracetamol.image_url = 'https://cdn.test/p.png'

      expect(paracetamol.photo_url).to eq('https://cdn.test/p.png')
    end

    it 'prefers an uploaded photo' do
      paracetamol.image.attach(io: StringIO.new('png'), filename: 'p.png', content_type: 'image/png')
      paracetamol.image_url = 'https://cdn.test/p.png'

      expect(paracetamol.photo_url).to include('/rails/active_storage/blobs/')
    end
  end

  describe 'image validation' do
    it 'rejects files that are not images' do
      paracetamol.image.attach(io: StringIO.new('text'), filename: 'a.txt', content_type: 'text/plain')

      expect(paracetamol).not_to be_valid
      expect(paracetamol.errors[:image]).to include('filetype not supported')
    end

    it 'rejects images over the size limit' do
      paracetamol.image.attach(io: StringIO.new('x' * (described_class::MAX_IMAGE_SIZE + 1)), filename: 'big.png', content_type: 'image/png')

      expect(paracetamol).not_to be_valid
      expect(paracetamol.errors[:image]).to include('is too big')
    end
  end
end
