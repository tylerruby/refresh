class OrdersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @orders = current_user.orders
  end

  def new
    @cart = cart
  end

  def create
    Order.transaction do
      @order = Order.create!(user: current_user, amount: cart.total)
      cart.shopping_cart_items.each do |cart_item|
        cart_item.update!(owner: @order)
      end
      cart.destroy!
    end

    flash[:success] = "Checkout was successful!"
    redirect_to root_path
  end
end
