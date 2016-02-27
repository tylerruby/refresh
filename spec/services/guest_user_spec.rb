require 'rails_helper'

RSpec.describe GuestUser do
  let(:session) { {} }
  let(:guest) { GuestUser.new(session) }
  let(:address) { create(:address) }
  let(:cart) { create(:cart) }

  subject { guest }

  it { is_expected.not_to be_persisted }

  it "reads the current address from the session" do
    session[:address_id] = address.id
    expect(guest.current_address).to eq address
  end

  it "writes the current address to the session on update" do
    guest.update!(current_address: address)
    expect(session[:address_id]).to eq address.id
  end

  it "reads the cart from the session" do
    session[:cart_id] = cart.id
    expect(guest.cart).to eq cart
  end

  it "writes the cart to the session on update" do
    guest.update!(cart: cart)
    expect(session[:cart_id]).to eq cart.id
  end

  it "doesn't updates attribute to nil if its key isn't present" do
    session[:address_id] = address.id
    expect { guest.update!(cart: cart) }.not_to change { session[:address_id] }
  end
end
