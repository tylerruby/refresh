class CartController < ApplicationController
  def index
    @cart_items = cart.shopping_cart_items.order(:created_at)
  end

  def add
    Cart.transaction do
      cloth_instance = ClothInstance.find_or_create_by!(cloth_instance_params)
      cart.add(cloth_instance, cloth_instance.price, quantity)
    end
    flash[:success] = 'Item added to the cart!'
    redirect_to :back
  end

  def remove
    cart.remove(cloth_instance, cart.item_for(cloth_instance).quantity)
    flash[:success] = 'Item removed from the cart.'
    redirect_to :back
  end

  def update
    cart.item_for(cloth_instance).update!(quantity: quantity, price: cloth_instance.price * quantity)
    flash[:success] = "Item's quantity updated to #{quantity}."
    redirect_to :back
  end

  private

    def cloth_instance_params
      params
      .require(:cloth_instance)
      .permit(:color, :size, :gender, :cloth_id)
      .tap do |hash|
        hash[:gender] = ClothInstance.genders[hash[:gender]]
      end
    end

    def quantity
      params.require(:quantity).to_i
    end

    def cloth_instance
      @cloth_instance ||= ClothInstance.find(params[:cloth_instance_id])
    end
end
