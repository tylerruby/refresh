json.cart do
  json.subtotal_cents(@cart.subtotal.cents)
  json.subtotal_currency(@cart.subtotal.currency.to_s)
  json.total_cents(@cart.total.cents)
  json.total_currency(@cart.total.currency.to_s)

  json.cart_items @cart_items do |cart_item|
    json.(cart_item, :quantity)
    json.subtotal_cents(cart_item.subtotal.to_money.cents)
    json.subtotal_currency(cart_item.subtotal.to_money.currency.to_s)

    json.menu_product do
      json.menu do
        json.(cart_item.item.menu, :id, :date)
      end

      json.product do
        product = cart_item.item.product
        json.(product, :id, :name, :description, :price_cents, :price_currency)
        json.image(product.image.url(:thumb))
      end
    end
  end
end
