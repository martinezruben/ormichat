json.id product.id
json.name product.name
json.sku product.sku
json.category product.category
json.brand product.brand
json.description product.description
json.ai_description product.ai_description
json.image_url product.photo_url
json.has_uploaded_image product.image.attached?
json.requires_prescription product.requires_prescription
json.active product.active
json.total_stock product.total_stock
json.variants product.variants do |variant|
  json.id variant.id
  json.name variant.name
  json.sku variant.sku
  json.price variant.price.to_f
  json.currency variant.currency
  json.stock variant.stock
  json.availability variant.availability
  json.active variant.active
end
