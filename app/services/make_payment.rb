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

      if stripe_token.present?
        user.update!(customer_id: customer.id)
      end

      order.update!(charge_id: charge.id)
      order.waiting_confirmation!
    end
  end

  private

    attr_accessor :order, :cart, :stripe_token
    delegate :user, to: :order

    def customer
      @customer ||= Stripe::Customer.create(
        card: stripe_token,
        description: 'Paying user',
        email: user.email
      )
    end

    def charge
      @charge ||= Stripe::Charge.create(
        :amount   => order.amount_cents,
        :currency => "usd",
        :customer => user.customer_id
      )
    end
end
