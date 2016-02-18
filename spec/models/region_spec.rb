require 'rails_helper'

RSpec.describe Region, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:address).dependent(:destroy) }
    it { is_expected.to have_many(:menus).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:address) }
  end
end
