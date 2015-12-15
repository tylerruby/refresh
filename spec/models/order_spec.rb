require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { build(:order) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:delivery_address) }
    it { is_expected.to validate_presence_of(:delivery_time) }
    it { is_expected.to validate_presence_of(:user) }
  end

  it do
      is_expected.to define_enum_for(:status).with %w(
        pending
        approved
        on_the_way
        delivered
        internal_failure
        external_failure
        canceled
      )
  end

  it "destroys cart_items when destroying order" do
    order.save!
    create(:cart_item, owner: order)
    expect { order.destroy }.to change { CartItem.count }.by(-1)
  end

  it "knows if it was charged" do
    expect(order).not_to be_charged
    order.charge_id = 'something'
    expect(order).to be_charged
  end

  it "knows if it was refunded" do
    expect(order).not_to be_refunded
    order.refund_id = 'something'
    expect(order).to be_refunded
  end
end
