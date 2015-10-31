class OrdersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    @cart = cart
    @cart.delivery_time = params.require(:delivery_time).to_i
    @order = Order.new
    if @cart.empty?
      flash[:info] = 'Your cart is empty, cannot checkout yet.'
      redirect_to root_path
    end
  end

  def create
    cart.delivery_time = order_params[:delivery_time].to_i
    order = Order.create!(order_params) do |order|
      order.user = current_user
      order.amount = cart.total
      order.status = 'pending'
    end

    begin
      Order.transaction do
        order.update!(cart_items: cart.shopping_cart_items)
        cart.reload.destroy!

        if stripe_token.present?
          customer = Stripe::Customer.create(
            card: stripe_token,
            description: 'Paying user',
            email: current_user.email
          )

          current_user.update!(customer_id: customer.id)
        end

        Stripe::Charge.create(
          :amount   => order.amount_cents,
          :currency => "usd",
          :customer => current_user.customer_id
        )

        order.waiting_confirmation!
        flash[:success] = "Checkout was successful! Waiting confirmation..."
      end
    rescue ActiveRecord::RecordInvalid
      order.internal_failure!
      flash[:danger] = "Something went wrong. Contact us and we'll solve the problem."
    rescue Stripe::StripeError => e
      order.external_failure!
      flash[:danger] = e.message
    end
    redirect_to root_path
  end

  private

    def order_params
      params.require(:order).permit(:delivery_time, :delivery_address)
    end

    def stripe_token
      params[:stripeToken]
    end
end
