module CartHelper
  def update_quantity_button(cart_item, increment)
    button_to(
      cart_update_path(
        quantity: cart_item.quantity + increment,
        menu_product_id: cart_item.item_id
      ),
      method: :patch,
      class: 'update-quantity'
    ) do
      yield
    end
  end
end
