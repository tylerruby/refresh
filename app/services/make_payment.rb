class MakePayment
  def initialize(options)
    self.order = options.fetch(:order)
    self.cart = options.fetch(:cart)
    self.stripe_token = options.fetch(:stripe_token)
  end

  def pay
    Order.transaction do
      order.update!(cart_items: cart.shopping_cart_items)
      cart.reload.destroy!

      if stripe_token.present? && order.source_id.blank?
        # Register a new credit card
        user.add_credit_card(stripe_token)
      end

      order.update!(charge_id: charge.id)
      order.waiting_confirmation!
    end
  end

  private

    attr_accessor :order, :cart, :stripe_token
    delegate :user, to: :order

    def charge
      charge_params = {
        amount: order.amount_cents,
        currency: 'usd',
        customer: user.customer_id}

        charge_params[:source] = order.source_id if order.source_id.present?

      @charge ||= Stripe::Charge.create(charge_params)
    end
end
