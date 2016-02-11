require 'rails_helper'

RSpec.describe City, type: :model do
  let(:city) { build(:city) }

  describe "associations" do
    it { is_expected.to have_many(:addresses).dependent(:nullify) }
  end

  it "strips city from surrounding empty space" do
    city.name = '  New York  '
    expect(city.name).to eq 'New York'
  end

  it "strips state from surrounding empty space" do
    city.state = '  GA  '
    expect(city.state).to eq 'GA'
  end

  describe "#full_name" do
    it { expect(city.full_name).to eq 'Atlanta/GA' }
  end
end
