require 'rails_helper'

RSpec.describe Cloth, type: :model do
  let(:cloth) { build(:cloth) }

  %i(chain name).each do |attribute|
    it "must validate presence of #{attribute}" do
      cloth = Cloth.new
      expect(cloth).not_to be_valid
      expect(cloth.errors).to have_key attribute
    end
  end

  %w(male female unisex).each do |gender|
    it "accepts #{gender} for gender" do
      expect { cloth.gender = gender }.not_to raise_error
    end
  end

  it "doesn't accept invalid values for gender" do
    expect { cloth.gender = 'other' }.to raise_error(ArgumentError)
  end

  it "saves the gender to the database" do
    cloth.update!(gender: 'male')
    expect(cloth.reload.gender).to eq 'male'
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

  it "creates cloth variants" do
    cloth.cloth_variants_configuration = '{ "L": ["red", "blue"], "M": ["blue", "green"] }'
    cloth.save!
    expect(cloth.cloth_variants.find_by(size: "L", color: "red")).not_to be_nil
    expect(cloth.cloth_variants.find_by(size: "L", color: "blue")).not_to be_nil
    expect(cloth.cloth_variants.find_by(size: "M", color: "blue")).not_to be_nil
    expect(cloth.cloth_variants.find_by(size: "M", color: "green")).not_to be_nil
  end
end
