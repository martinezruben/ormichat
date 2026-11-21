require 'rails_helper'

RSpec.describe Products::SampleCatalog do
  let(:account) { Account.create!(name: 'Farmacia Test') }

  it 'loads 20 pharmacy products with photo, guidance, varieties, price and stock' do
    products = described_class.seed!(account)

    expect(products.size).to eq(20)
    expect(account.products.count).to eq(20)
    expect(account.products.pluck(:image_url)).to all(start_with('/product-samples/'))
    expect(account.products.pluck(:ai_description)).to all(be_present)
    expect(account.products.map { |product| product.variants.size }).to all(be >= 2)
    expect(ProductVariant.where(account: account).pluck(:price)).to all(be_positive)
  end

  it 'covers in stock, low stock and out of stock varieties' do
    described_class.seed!(account)

    availability = ProductVariant.where(account: account).map(&:availability).uniq
    expect(availability).to contain_exactly('in_stock', 'low_stock', 'out_of_stock')
  end

  it 'has a photo file for every product' do
    expect(described_class::PRODUCTS.map(&:first)).to all(satisfy { |slug| Rails.public_path.join('product-samples', "#{slug}.svg").exist? })
  end

  it 'is safe to run twice' do
    described_class.seed!(account)

    expect { described_class.seed!(account) }.not_to(change { [account.products.count, ProductVariant.where(account: account).count] })
  end

  it 'does not overwrite what the account edited' do
    described_class.seed!(account)
    variant = ProductVariant.find_by(account: account, sku: 'PH-PARACETAMOL_500-1')
    variant.update!(price: 10, stock: 7)
    variant.product.update!(ai_description: 'Texto propio')

    described_class.seed!(account)

    expect(variant.reload).to have_attributes(price: 10, stock: 7)
    expect(variant.product.reload.ai_description).to eq('Texto propio')
  end

  it 'fills the guidance text of products that were loaded without it' do
    described_class.seed!(account)
    account.products.update_all(ai_description: nil) # rubocop:disable Rails/SkipsModelValidations

    described_class.seed!(account)

    expect(account.products.pluck(:ai_description)).to all(be_present)
  end
end
