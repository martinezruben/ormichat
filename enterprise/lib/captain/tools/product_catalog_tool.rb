class Captain::Tools::ProductCatalogTool < Captain::Tools::BasePublicTool
  description 'Look up products in the store catalog to answer about price, available varieties, stock and photos'
  parameter :query, type: 'string', description: 'Product name, brand or need mentioned by the customer (e.g. "paracetamol", "protector solar")'
  parameter :category, type: 'string', description: 'Optional category to narrow the search (e.g. "Analgésicos")', required: false

  def perform(_tool_context, query:, category: nil)
    log_tool_usage('searching', { query: query, category: category })

    products = Product.where(account_id: @assistant.account_id).lookup(query: query, category: category)
    return "No products found for: #{query}" if products.empty?

    Products::ChatFormatter.assistant_context(products)
  end

  private

  def safe_to_run_after_new_customer_message?
    true
  end
end
