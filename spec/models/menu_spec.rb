require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:menu_products) }
    it { is_expected.to have_many(:products).through(:menu_products) }
    it { is_expected.to belong_to(:region) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:region) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:region_id) }
  end
end
