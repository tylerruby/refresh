require 'rails_helper'

RSpec.describe MakePayment do
  let(:delivery_time) { 1 }
  let(:user) { create(:user) }
  let(:cart) { create(:cart, delivery_time: delivery_time) }
  let!(:cart_items) { 2.times.map { cart.add(create(:cloth_instance), 1) } }
  let(:order) { create(:order, user: user, amount: cart.total, status: 'pending') }

  let(:customer_double) { double('Stripe::Customer', id: 'some customer id') }
  let(:charge_double) { double('Stripe::Charge', id: 'some charge id') }
  let(:token) { 'some token' }

  before do
    allow(Stripe::Customer).to receive(:create).with(
      card:        token,
      description: 'Paying user',
      email:       user.email
    ).and_return(customer_double)

    allow(Stripe::Charge).to receive(:create).with(
      amount:   cart.total.cents,
      currency: "usd",
      customer: customer_double.id
    ).and_return(charge_double)

    MakePayment.new(cart: cart, order: order, stripe_token: token).pay
  end

  it { expect(user.customer_id).to eq customer_double.id }

  it { expect(order.cart_items).to eq cart_items }
  it { expect(order.user).to eq user }
  it { expect(order.status).to eq 'waiting_confirmation' }
  it { expect(order.charge_id).to eq charge_double.id }

  it { expect(Cart.exists? cart.id).to be false }
  it { expect(Stripe::Customer).to have_received(:create) }
  it { expect(Stripe::Charge).to have_received(:create) }
end
