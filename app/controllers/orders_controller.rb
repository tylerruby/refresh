class OrdersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    @cart = cart
    @order = Order.new
    if @cart.empty?
      flash[:info] = 'Your cart is empty, cannot checkout yet.'
      redirect_to root_path
    end
  end

  def create
    @order = Order.new(order_params) do |order|
      order.user = current_user
      order.amount = cart.total
      order.status = 'pending'
      order.stripe_token = params[:stripeToken]
    end

    if @order.save
      begin
        MakePayment.new(order: @order, cart: cart).pay
        flash[:success] = "Checkout was successful! You'll receive your order in 15 minutes!"
      rescue ActiveRecord::RecordInvalid
        @order.internal_failure!
        flash[:danger] = "Something went wrong. Contact us and we'll solve the problem."
      rescue Stripe::StripeError => e
        @order.external_failure!
        flash[:danger] = e.message
      end
      redirect_to root_path
    else
      flash[:danger] = @order.errors.messages.values.flatten.first
      render :new, status: :unprocessable_entity
    end
  end

  private

    def order_params
      params.require(:order).permit(:delivery_address, :observations, :source_id)
    end
end
