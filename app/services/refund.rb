class Refund
  def initialize(options)
    self.order = options.fetch(:order)
    self.reason = options.fetch(:reason, :requested_by_customer)
    self.message = options.fetch(:message)
  end

  def create
    response = Stripe::Refund.create(charge: charge_id, reason: reason)
    order.update!(refund_id: response.id, status: :canceled)
    RefundMailer.refund(user, message).deliver
  end

  private

    attr_accessor :order, :reason, :message
    delegate :charge_id, :user, to: :order
end
