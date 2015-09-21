require 'rails_helper'

RSpec.describe Cart, type: :model do
  it "describes one item" do
    cart = Cart.create!
    cloth_instance = create(:cloth_instance)
    cart.add(cloth_instance, 10.to_money, 1)
    expect(cart.description).to eq '1 cloth ($10.00)'
  end

  it "describes more than one item" do
    cart = Cart.create!
    cloth_instance = create(:cloth_instance)
    cart.add(cloth_instance, 10.to_money, 2)
    expect(cart.description).to eq '2 clothes ($20.00)'
  end
end
