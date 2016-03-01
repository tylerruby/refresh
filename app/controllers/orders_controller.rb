class OrdersController < ApplicationController
  before_filter :authenticate!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    authorize cart, :checkout?
    @cart = cart
    @order = Order.new
    if @cart.empty?
      flash[:info] = 'Your cart is empty, cannot checkout yet.'
      redirect_to root_path
    end
  end

  def create
    authorize cart, :checkout?
    @order = Order.new(order_params) do |order|
      order.user = current_user
      order.delivery_address = current_user.current_address.full_address
      order.amount = cart.total
      order.status = 'pending'
      order.stripe_token = params[:stripeToken]
    end

    if @order.save
      redirect = -> { redirect_to root_path }
      begin
        MakePayment.new(order: @order, cart: cart).pay
        render_success "Checkout was successful! You'll receive your order in 15 minutes!", html_render_method: redirect
      rescue ActiveRecord::RecordInvalid
        @order.internal_failure!
        render_error "Something went wrong. Contact us and we'll solve the problem.", status: :unprocessable_entity, html_render_method: redirect
      rescue Stripe::StripeError => e
        @order.external_failure!
        render_error e.message, html_render_method: redirect
      end
    else
      render_error @order.errors.messages.values.flatten.first, status: :unprocessable_entity, html_render_method: -> {
        render :new, status: :unprocessable_entity
      }
    end
  end

  private

    def order_params
      params.require(:order).permit(:delivery_address, :observations, :source_id)
    end

    def render_success(message, html_render_method: -> { render })
      respond_to do |format|
        format.json { head :ok }
        format.html do
          flash[:success] = message
          html_render_method.call
        end
      end
    end

    def render_error(message, status: :bad_request, html_render_method: -> {render })
      respond_to do |format|
        format.json { render json: { error: message }, status: status }
        format.html do
          flash[:danger] = message
          html_render_method.call
        end
      end
    end
end
