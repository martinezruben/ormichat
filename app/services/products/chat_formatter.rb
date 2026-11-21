# Renders catalog products as plain text so the chat assistants can quote price, stock and photo.
class Products::ChatFormatter
  AVAILABILITY = {
    'in_stock' => 'in stock',
    'low_stock' => 'low stock',
    'out_of_stock' => 'out of stock'
  }.freeze

  def self.format(products)
    products.map { |product| new(product).to_text }.join("\n\n")
  end

  def initialize(product)
    @product = product
  end

  def to_text
    lines = ["Product: #{@product.name} (SKU #{@product.sku})", "Category: #{@product.category}"]
    lines << "Brand: #{@product.brand}" if @product.brand.present?
    lines << "Description: #{@product.description}" if @product.description.present?
    lines << "Requires prescription: #{@product.requires_prescription ? 'yes' : 'no'}"
    lines << "Photo: #{image_url}" if image_url.present?
    lines << 'Varieties:'
    lines.concat(@product.variants.select(&:active).map { |variant| variant_line(variant) })
    lines.join("\n")
  end

  private

  def image_url
    url = @product.image_url.to_s
    url.start_with?('/') ? "#{ENV.fetch('FRONTEND_URL', '')}#{url}" : url
  end

  def variant_line(variant)
    price = Kernel.format('%.2f', variant.price)
    stock = variant.stock.positive? ? "#{AVAILABILITY[variant.availability]}, #{variant.stock} units" : AVAILABILITY[variant.availability]
    "- #{variant.name}: #{price} #{variant.currency}, #{stock}"
  end
end
