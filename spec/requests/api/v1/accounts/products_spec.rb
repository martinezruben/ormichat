require 'rails_helper'

RSpec.describe 'Products API' do
  let(:account) { Account.create!(name: 'Farmacia Test') }
  let(:other_account) { Account.create!(name: 'Otra Farmacia') }
  let(:admin) { User.create!(name: 'Admin', email: 'admin@test.com', password: 'Password1!', password_confirmation: 'Password1!') }
  let(:agent) { User.create!(name: 'Agente', email: 'agente@test.com', password: 'Password1!', password_confirmation: 'Password1!') }
  let(:admin_headers) { { 'api_access_token' => admin.access_token.token } }
  let(:agent_headers) { { 'api_access_token' => agent.access_token.token } }
  let(:base_path) { "/api/v1/accounts/#{account.id}/products" }
  let(:png) { Rack::Test::UploadedFile.new(StringIO.new("\x89PNG\r\n\x1a\n"), 'image/png', original_filename: 'foto.png') }
  let(:text_file) { Rack::Test::UploadedFile.new(StringIO.new('hola'), 'text/plain', original_filename: 'nota.txt') }

  let!(:paracetamol) do
    account.products.create!(
      name: 'Paracetamol 500 mg', sku: 'P-1', category: 'Analgésicos', ai_description: 'Para dolor de cabeza',
      variants_attributes: [{ name: 'Caja x 10', sku: 'P-1-A', price: 8.5, stock: 20 }]
    )
  end
  let!(:gel) do
    account.products.create!(
      name: 'Alcohol en gel', sku: 'A-1', category: 'Higiene',
      variants_attributes: [{ name: 'Botella 1 L', sku: 'A-1-A', price: 41, stock: 0 }]
    )
  end
  let!(:foreign_product) do
    other_account.products.create!(name: 'Ajeno', sku: 'X-1', category: 'Otro',
                                   variants_attributes: [{ name: 'U', sku: 'X-1-A', price: 1, stock: 1 }])
  end

  before do
    AccountUser.create!(account: account, user: admin, role: :administrator)
    AccountUser.create!(account: account, user: agent, role: :agent)
  end

  describe 'GET /products' do
    it 'requires authentication' do
      get base_path

      expect(response).to have_http_status(:unauthorized)
    end

    it 'lists the products of the account with their varieties' do
      get base_path, headers: agent_headers

      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body['meta']).to include('count' => 2, 'current_page' => 1)
      expect(body['payload'].pluck('name')).to contain_exactly('Paracetamol 500 mg', 'Alcohol en gel')
      variant = body['payload'].find { |product| product['sku'] == 'P-1' }['variants'].first
      expect(variant).to include('price' => 8.5, 'stock' => 20, 'availability' => 'in_stock', 'currency' => 'DOP')
    end

    it 'filters by search, category and stock' do
      get base_path, params: { q: 'dolor' }, headers: agent_headers
      expect(response.parsed_body['payload'].pluck('sku')).to eq(['P-1'])

      get base_path, params: { category: 'Higiene' }, headers: agent_headers
      expect(response.parsed_body['payload'].pluck('sku')).to eq(['A-1'])

      get base_path, params: { in_stock: true }, headers: agent_headers
      expect(response.parsed_body['payload'].pluck('sku')).to eq(['P-1'])
    end

    it 'returns the guidance text for the assistant' do
      get "#{base_path}/#{paracetamol.id}", headers: agent_headers

      expect(response.parsed_body['ai_description']).to eq('Para dolor de cabeza')
    end

    it 'does not show products of another account' do
      get "#{base_path}/#{foreign_product.id}", headers: admin_headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'write access' do
    let(:payload) do
      { product: { name: 'Vitamina C', sku: 'V-1', category: 'Vitaminas', ai_description: 'Para reforzar la dieta',
                   variants_attributes: [{ name: 'Tubo x 10', sku: 'V-1-A', price: 28, stock: 5 }] } }
    end

    it 'lets an administrator create a product with varieties' do
      expect { post base_path, params: payload, headers: admin_headers, as: :json }.to change(account.products, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['variants'].first).to include('name' => 'Tubo x 10', 'availability' => 'low_stock')
    end

    it 'lets an administrator update stock and remove a variety' do
      variant = paracetamol.variants.first
      params = { product: { variants_attributes: [{ id: variant.id, stock: 50 }, { name: 'Caja x 20', sku: 'P-1-B', price: 15, stock: 4 }] } }

      patch "#{base_path}/#{paracetamol.id}", params: params, headers: admin_headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(variant.reload.stock).to eq(50)
      expect(paracetamol.variants.count).to eq(2)

      patch "#{base_path}/#{paracetamol.id}", params: { product: { variants_attributes: [{ id: variant.id, _destroy: true }] } },
                                              headers: admin_headers, as: :json
      expect(paracetamol.variants.pluck(:sku)).to eq(['P-1-B'])
    end

    it 'rejects invalid data' do
      post base_path, params: { product: { name: '', sku: 'V-2', category: 'X' } }, headers: admin_headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'lets an administrator delete a product with its varieties' do
      expect { delete "#{base_path}/#{gel.id}", headers: admin_headers }.to change(account.products, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it 'does not let an agent create, update or delete' do
      post base_path, params: payload, headers: agent_headers, as: :json
      expect(response).to have_http_status(:unauthorized)

      patch "#{base_path}/#{paracetamol.id}", params: { product: { name: 'Hack' } }, headers: agent_headers, as: :json
      expect(response).to have_http_status(:unauthorized)

      delete "#{base_path}/#{paracetamol.id}", headers: agent_headers
      expect(response).to have_http_status(:unauthorized)
      expect(paracetamol.reload.name).to eq('Paracetamol 500 mg')
    end
  end

  describe 'photo upload' do
    it 'attaches a photo and serves it as the product image' do
      post "#{base_path}/#{paracetamol.id}/image", params: { image: png }, headers: admin_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('has_uploaded_image' => true)
      expect(response.parsed_body['image_url']).to include('/rails/active_storage/blobs/')
    end

    it 'rejects files that are not images' do
      post "#{base_path}/#{paracetamol.id}/image", params: { image: text_file }, headers: admin_headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(paracetamol.reload.image).not_to be_attached
    end

    it 'removes the uploaded photo' do
      paracetamol.image.attach(io: StringIO.new('png'), filename: 'p.png', content_type: 'image/png')

      delete "#{base_path}/#{paracetamol.id}/image", headers: admin_headers

      expect(response.parsed_body).to include('has_uploaded_image' => false)
      expect(paracetamol.reload.image).not_to be_attached
    end

    it 'does not let an agent upload' do
      post "#{base_path}/#{paracetamol.id}/image", params: { image: png }, headers: agent_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
