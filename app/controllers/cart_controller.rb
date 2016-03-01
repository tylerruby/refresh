class CartController < ApplicationController
  def index
    @cart = cart
    @cart_items = @cart.shopping_cart_items.order(:created_at)
  end

  def add
    authorize menu_product
    Cart.transaction do
      cart.add(menu_product, menu_product.product.price, quantity)
    end

    respond_to do |format|
      format.json { head :ok }
      format.html do
        render layout: false
      end
    end
  end

  def remove
    cart.remove(menu_product, cart.item_for(menu_product).quantity)

    respond_to do |format|
      format.json { head :ok }
      format.html do
        render layout: false
      end
    end
  end

  def update
    if (quantity < 0) then
      return
    end

    cart.item_for(menu_product).update!(quantity: quantity)

    if (quantity == 0) then
      cart.remove(menu_product, cart.item_for(menu_product).quantity)
    end

    respond_to do |format|
      format.json { head :ok }
      format.html do
        render layout: false
      end
    end
  end

  def update_items_delivery_time
    cart
      .shopping_cart_items
      .joins(menu_product: :menu)
      .where(menus: { date: params[:delivery_date] })
      .each do |cart_item|
        cart_item.update!(delivery_time: params[:delivery_time])
      end

    respond_to do |format|
      format.json { head :ok }
      format.html do
        render layout: false
      end
    end
  end

  private

    def quantity
      params.require(:quantity).to_i
    end

    def menu_product
      @menu_product ||= MenuProduct.find(params[:menu_product_id])
    end
end
