require 'rails_helper'

RSpec.describe MakePayment do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:delivery_time) { 1 }
  let(:user) { create(:user) }
  let(:cart) { create(:cart, delivery_time: delivery_time) }
  let!(:cart_items) { 2.times.map { cart.add(create(:product), 1) } }
  let(:order) { create(:order, user: user, amount: cart.total, status: 'pending') }

  let(:charge_double) { double('Stripe::Charge', id: 'some charge id') }
  let(:token) { stripe_helper.generate_card_token }

  before do
    allow(Stripe::Charge).to receive(:create).with(
      amount:   cart.total.cents,
      currency: "usd",
      customer: user.customer.id
    ).and_return(charge_double)

    MakePayment.new(cart: cart, order: order, stripe_token: token).pay
  end

  it { expect(order.cart_items).to eq cart_items }
  it { expect(order.user).to eq user }
  it { expect(order.status).to eq 'waiting_confirmation' }
  it { expect(order.charge_id).to eq charge_double.id }

  it { expect(Cart.exists? cart.id).to be false }
  it { expect(Stripe::Charge).to have_received(:create) }
end
