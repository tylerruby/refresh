json.(@menu, :date)
json.products @menu.products do |product|
  json.(product, :id, :name, :description, :price_cents, :price_currency)
  json.image(product.image.url(:thumb))
end
