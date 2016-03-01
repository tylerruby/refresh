require 'rails_helper'

RSpec.describe Product, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:menu_products) }
    it { is_expected.to have_many(:menus).through(:menu_products) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
