json.meta do
  json.count @products_count
  json.current_page @products.current_page
  json.per_page Api::V1::Accounts::ProductsController::RESULTS_PER_PAGE
end
json.payload do
  json.array! @products do |product|
    json.partial! 'api/v1/accounts/products/product', product: product
  end
end
