require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:menu_products) }
    it { is_expected.to have_many(:products).through(:menu_products) }
  end
end
