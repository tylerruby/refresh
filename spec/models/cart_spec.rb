require 'rails_helper'

RSpec.describe Cart, type: :model do
  it "describes one item" do
    cart = Cart.create!
    cart.delivery_time = 1
    product = create(:product)
    cart.add(product, 10.to_money, 1)
    expect(cart.description).to eq '1 products ($10.00)'
  end

  it "describes more than one item" do
    cart = Cart.create!
    cart.delivery_time = 1
    product = create(:product)
    cart.add(product, 10.to_money, 2)
    expect(cart.description).to eq '2 products ($20.00)'
  end
end
