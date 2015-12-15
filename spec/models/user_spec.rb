require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:addresses).dependent(:destroy) }
    it { is_expected.to belong_to(:current_address) }
  end

  it { is_expected.to accept_nested_attributes_for(:addresses).allow_destroy(true) }

  it "defaults to any address if there's not current_address" do
    user = create(:user)
    address = create(:address)
    user.addresses << address

    expect(user.current_address).to eq address
  end
end
