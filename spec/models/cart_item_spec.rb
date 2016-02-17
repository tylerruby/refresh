require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:item) }
    it { is_expected.to delegate_method(:image).to(:item) }
    it { is_expected.to delegate_method(:store).to(:item) }
  end
end
