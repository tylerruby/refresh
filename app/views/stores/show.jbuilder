json.store do
  json.(@store, :id, :name, :opens_at, :closes_at)
  json.image(@store.image.url(:thumb))

  json.products @available_products do |product|
    json.(product, :id, :name, :description, :price_cents, :price_currency)
    json.image(product.image.url(:thumb))
  end
end
