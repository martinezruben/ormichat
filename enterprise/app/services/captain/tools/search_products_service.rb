class Captain::Tools::SearchProductsService < Captain::Tools::BaseTool
  def self.name
    'search_products'
  end
  description 'Look up products in the store catalog to answer about price, available varieties, stock and photos'

  parameter :query, description: 'Product name, brand or need mentioned by the customer', required: true
  parameter :category, description: 'Optional category to narrow the search', required: false

  def execute(query:, category: nil)
    Rails.logger.info { "#{self.class.name}: #{query}" }

    products = Product.where(account_id: assistant.account_id).lookup(query: query, category: category)
    return "No products found for: #{query}" if products.empty?

    Products::ChatFormatter.assistant_context(products)
  end
end
