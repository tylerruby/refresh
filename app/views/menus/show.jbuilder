json.(@menu, :date)
json.menu_products @menu.menu_products do |menu_product|
  json.(menu_product, :id)

  json.menu do
    json.(menu_product.menu, :id, :date)
  end

  json.product do
    json.(menu_product.product, :id, :name, :description, :price_cents, :price_currency)
    json.image(menu_product.product.image.url(:thumb))
  end
end
