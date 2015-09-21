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

      customer = Stripe::Customer.create(
        card: params[:stripeToken],
        description: 'Paying user',
        email: current_user.email
      )

      current_user.update!(customer_id: customer.id)

      Stripe::Charge.create(
        :amount   => @order.amount_cents,
        :currency => "usd",
        :customer => current_user.customer_id
      )
    end

    flash[:success] = "Checkout was successful!"
    redirect_to root_path
  end
end
