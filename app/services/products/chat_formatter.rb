# Renders catalog products as plain text so the chat assistants can quote price, stock and photo.
class Products::ChatFormatter
  AVAILABILITY = {
    'in_stock' => 'in stock',
    'low_stock' => 'low stock',
    'out_of_stock' => 'out of stock'
  }.freeze

  INSTRUCTIONS = 'Use only this catalog information to recommend products based on what the customer needs. Do not give medical advice.'.freeze

  def self.format(products)
    products.map { |product| new(product).to_text }.join("\n\n")
  end

  def self.assistant_context(products)
    "#{INSTRUCTIONS}\n\n#{format(products)}"
  end

  def initialize(product)
    @product = product
  end

  def to_text
    (header_lines + guidance_lines + ['Varieties:'] + variant_lines).join("\n")
  end

  private

  def header_lines
    lines = ["Product: #{@product.name} (SKU #{@product.sku})", "Category: #{@product.category}"]
    lines << "Brand: #{@product.brand}" if @product.brand.present?
    lines << "Description: #{@product.description}" if @product.description.present?
    lines
  end

  def guidance_lines
    lines = []
    lines << "When to recommend and guidance: #{@product.ai_description}" if @product.ai_description.present?
    lines << "Requires prescription: #{@product.requires_prescription ? 'yes' : 'no'}"
    lines << "Photo: #{@product.photo_url}" if @product.photo_url.present?
    lines
  end

  def variant_lines
    @product.variants.select(&:active).map { |variant| variant_line(variant) }
  end

  def variant_line(variant)
    price = Kernel.format('%.2f', variant.price)
    stock = variant.stock.positive? ? "#{AVAILABILITY[variant.availability]}, #{variant.stock} units" : AVAILABILITY[variant.availability]
    "- #{variant.name}: #{price} #{variant.currency}, #{stock}"
  end
end
