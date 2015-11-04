require 'rails_helper'

RSpec.describe Refund do
  let(:order) { create(:order, charge_id: 'some charge id') }
  let(:message) { "Your order could not be delivered." }
  let(:refund) { Refund.new(order: order, message: message) }
  let(:stripe_refund) { double("Stripe::Refund", id: 'some refund id') }

  before do
    allow(Stripe::Refund).to receive(:create).and_return(stripe_refund)
  end

  it "refunds the user with Stripe" do
    expect(Stripe::Refund).to receive(:create).with(
      charge: order.charge_id,
      reason: :requested_by_customer
    )
    refund.create
  end

  it "sends an email with the message" do
    mailer = double("RefundMailer", deliver: nil)
    expect(RefundMailer).to receive(:refund)
                            .with(order.user, message)
                            .and_return(mailer)
    refund.create
    expect(mailer).to have_received(:deliver)
  end

  it "updates the order with the refund id" do
    expect { refund.create }.to change { order.reload.refund_id }
                                .from(nil)
                                .to(stripe_refund.id)
  end

  it "changes the order status to canceled" do
    expect { refund.create }.to change { order.reload.status }
                                .from('waiting_confirmation')
                                .to('canceled')
  end
end
