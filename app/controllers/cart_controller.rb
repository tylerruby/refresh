class CartController < ApplicationController
  def index
    @cart = cart
  end

  def add
    cloth_instance = ClothInstance.create!(cloth_instance_params)
    cart.add(cloth_instance, cloth_instance.cloth.price * quantity, quantity)
    flash[:success] = 'Item added to the cart!'
    redirect_to :back
  end

  def remove
    cart.remove(cloth_instance)
    flash[:success] = 'Item removed from the cart.'
    redirect_to :back
  end

  def update
    cart.update_quantity_for cloth_instance, quantity
    flash[:success] = "Item's quantity updated to #{quantity}."
    redirect_to :back
  end

  private

    def cart
      cart = Cart.find_by(id: session[:cart_id]) || Cart.create!
      session[:cart_id] ||= cart.id
      cart
    end

    def cloth_instance_params
      params.require(:cloth_instance).permit(:color, :size, :gender, :cloth_id)
    end

    def quantity
      params.require(:quantity).to_i
    end

    def cloth_instance
      @cloth_instance ||= ClothInstance.find(params[:cloth_instance_id])
    end
end
