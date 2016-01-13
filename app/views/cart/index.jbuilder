json.cart do
  json.subtotal_cents(@cart.subtotal.cents)
  json.subtotal_currency(@cart.subtotal.currency.to_s)
  json.total_cents(@cart.total.cents)
  json.total_currency(@cart.total.currency.to_s)

  json.cart_items @cart_items do |cart_item|
    json.(cart_item, :quantity)
    json.subtotal_cents(cart_item.subtotal.to_money.cents)
    json.subtotal_currency(cart_item.subtotal.to_money.currency.to_s)

    json.product do
      product = cart_item.item
      json.(product, :id, :name, :description, :price_cents, :price_currency)
      json.image(product.image.url(:thumb))

      json.store do
        json.(product.store, :id, :name)
      end
    end
  end
end
