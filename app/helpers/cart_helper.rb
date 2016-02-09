module CartHelper
  def update_quantity_button(cart_item, increment)
    button_to(
      {
        controller: :cart,
        action: :update,
        quantity: cart_item.quantity + increment,
        product_id: cart_item.item_id
      },
      method: :patch,
      class: 'btn btn-sm btn-default update-quantity'
    ) do
      yield
    end
  end
end
