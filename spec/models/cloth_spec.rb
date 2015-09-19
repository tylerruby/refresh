require 'rails_helper'

RSpec.describe Cloth, type: :model do
  %i(chain name).each do |attribute|
    it "must validate presence of #{attribute}" do
      cloth = Cloth.new
      expect(cloth).not_to be_valid
      expect(cloth.errors).to have_key attribute
    end
  end

  it "has many cloth variants" do
    cloth = create(:cloth)
    expect(cloth.cloth_variants).to eq []

    cloth_variant = build(:cloth_variant, cloth: nil)
    expect { cloth.cloth_variants << cloth_variant }.not_to raise_error

    expect(cloth.cloth_variants.reload).to eq [cloth_variant]
  end

  describe "#colors" do
    let(:cloth) { build(:cloth) }

    it "splits string containing colors" do
      cloth.colors = "red,blue"
      expect(cloth.colors).to eq %w(red blue)
    end

    it "removes whitespace from colors" do
      cloth.colors = "  red  ,  blue  "
      expect(cloth.colors).to eq %w(red blue)
    end

    it "accepts an array" do
      cloth.colors = %w(red blue)
      expect(cloth.colors).to eq %w(red blue)
    end

    it "removes whitepsace from colors in array" do
      cloth.colors = ["  red  ", "  blue  "]
      expect(cloth.colors).to eq %w(red blue)
    end
  end
end
