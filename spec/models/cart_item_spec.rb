require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:item) }
    it { is_expected.to delegate_method(:image).to(:item) }
  end

  describe "validations" do
    it do
      is_expected
        .to validate_inclusion_of(:delivery_time)
        .in_array([
          '11:30 AM',
          '12:00 PM',
          '12:30 PM',
          '01:00 PM',
          '01:30 PM',
          '02:00 PM',
          '02:30 PM'
        ])
    end
  end
end
