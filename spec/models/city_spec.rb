require 'rails_helper'

RSpec.describe City, type: :model do
  let(:city) { build(:city) }

  describe "associations" do
    it { is_expected.to have_many(:addresses) }
  end

  it "strips city from surrounding empty space" do
    city.name = '  New York  '
    expect(city.name).to eq 'New York'
  end

  it "strips state from surrounding empty space" do
    city.state = '  GA  '
    expect(city.state).to eq 'GA'
  end
end
