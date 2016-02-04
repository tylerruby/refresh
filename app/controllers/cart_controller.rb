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

    respond_to do |format|
      format.json { head :ok }
      format.html do
        render layout: false
      end
    end
  end

  def remove
    cart.remove(product, cart.item_for(product).quantity)

    respond_to do |format|
      format.json { head :ok }
      format.html do
        render layout: false
      end
    end
  end

  def update
    cart.item_for(product).update!(quantity: quantity)

    respond_to do |format|
      format.json { head :ok }
      format.html do
        flash[:success] = "Item's quantity updated to #{quantity}."
        redirect_to :back
      end
    end
  end

  private

    def quantity
      params.require(:quantity).to_i
    end

    def product
      @product ||= Product.find(params[:product_id])
    end
end
