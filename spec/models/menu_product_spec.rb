require 'rails_helper'

RSpec.describe MenuProduct, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:menu) }
    it { is_expected.to belong_to(:product) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:product) }
    it { is_expected.to delegate_method(:image).to(:product) }
    it { is_expected.to delegate_method(:image_url).to(:product) }
    it { is_expected.to delegate_method(:price).to(:product) }
    it { is_expected.to delegate_method(:description).to(:product) }
    it { is_expected.to delegate_method(:restaurant).to(:product) }
  end
end
