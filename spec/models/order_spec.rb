require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { build(:order) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:delivery_address) }
    it { is_expected.to validate_presence_of(:delivery_time) }
    it { is_expected.to validate_presence_of(:user) }
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
