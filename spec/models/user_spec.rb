require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:orders).dependent(:destroy) }
    it { is_expected.to belong_to(:current_address).dependent(:destroy) }
    it { is_expected.to have_one(:cart) }
  end
end
