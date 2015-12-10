class CartController < ApplicationController
  def index
    @cart = cart
    @cart_items = @cart.shopping_cart_items.order(:created_at)
  end

  def add
    authorize product.store
    Cart.transaction do
      cart.add(product, product.price, quantity)
    end
    flash[:success] = 'Item added to the cart!'
    redirect_to :back
  end

  def remove
    cart.remove(product, cart.item_for(product).quantity)
    flash[:success] = 'Item removed from the cart.'
    redirect_to :back
  end

  def update
    cart.item_for(product).update!(quantity: quantity)
    flash[:success] = "Item's quantity updated to #{quantity}."
    redirect_to :back
  end

  private

    def quantity
      params.require(:quantity).to_i
    end

    def product
      @product ||= Product.find(params[:product_id])
    end
end
