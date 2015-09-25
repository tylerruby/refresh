require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { build(:order) }

  it "validates presence of user" do
    order = Order.new
    expect(order).not_to be_valid
    expect(order.errors).to have_key :user
  end

  it "only accepts valid status" do
    %w(pending waiting_confirmation on_the_way delivered internal_failure external_failure).each do |status|
      expect { order.status = status }.not_to raise_error
      expect(order).to be_valid
    end
    expect { order.status = 'some invalid status' }.to raise_error(ArgumentError)
  end

  it "destroys cart_items when destroying order" do
    order.save!
    create(:cart_item, owner: order)
    expect { order.destroy }.to change { CartItem.count }.by(-1)
  end
end
