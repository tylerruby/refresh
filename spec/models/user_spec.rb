require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:orders).dependent(:destroy) }
    it { is_expected.to belong_to(:current_address).dependent(:destroy) }
    it { is_expected.to have_one(:cart) }
  end

  describe "validations" do
    it { is_expected.to allow_value("(012) 345-6789").for(:mobile_number) }
    it { is_expected.not_to allow_value("345-6789").for(:mobile_number) }
    it { is_expected.not_to allow_value("012 345 6789").for(:mobile_number) }
    it { is_expected.not_to allow_value("012-345-6789").for(:mobile_number) }
  end
end
