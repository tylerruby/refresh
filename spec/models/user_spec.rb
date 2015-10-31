require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:addresses).dependent(:destroy) }
  end

  it { is_expected.to accept_nested_attributes_for(:addresses).allow_destroy(true) }
end
