class AddToCart
  attr_reader :cart, :cloth_instance, :quantity

  def initialize(cart, cloth_instance, quantity)
    @cart = cart
    @cloth_instance = cloth_instance
    @quantity = quantity
  end

  def add!
    if cart_item.present?
      update_existing_item!
    else
      add_new_item!
    end
  end

  private

    def cart_item
      @cart_item ||= cart.item_for cloth_instance
    end

    def update_existing_item!
      new_quantity = quantity + cart_item.quantity
      new_price = cloth_instance.price * new_quantity
      cart_item.update!(price: new_price, quantity: new_quantity)
    end

    def add_new_item!
      price = cloth_instance.price * quantity
      cart.add(cloth_instance, price, quantity)
    end
end
