require 'rails_helper'

RSpec.describe Order, type: :model do
  it "validates presence of user" do
    order = Order.new
    expect(order).not_to be_valid
    expect(order.errors).to have_key :user
  end
end
