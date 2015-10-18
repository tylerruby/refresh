require 'rails_helper'

RSpec.describe Cloth, type: :model do
  let(:cloth) { build(:cloth) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_presence_of(:chain) }

    %w(male female unisex).each do |gender|
      it "accepts #{gender} for gender" do
        expect { cloth.gender = gender }.not_to raise_error
      end
    end

    it "doesn't accept invalid values for gender" do
      expect { cloth.gender = 'other' }.to raise_error(ArgumentError)
    end

    it "doesn't accept a gender that's different than the category's" do
      cloth.category = create(:category, male: false, female: true)
      cloth.gender = 'male'
      expect(cloth).not_to be_valid
      expect(cloth.errors).to have_key :gender
    end

    it "accepts any gender if the category is unisex" do
      cloth.category = create(:category, male: true, female: true)
      cloth.gender = 'male'
      expect(cloth).to be_valid
    end

    it "accepts any category if the gender is unisex" do
      cloth.category = create(:category, male: false, female: true)
      cloth.gender = 'unisex'
      expect(cloth).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:cloth_variants) }
    it { is_expected.to belong_to(:category) }
  end

  it "destroys child cloth variants when destroying cloth" do
    cloth.save!
    create(:cloth_variant, cloth: cloth)
    expect { cloth.destroy }.to change { ClothVariant.count }.by(-1)
  end

  it "saves the gender to the database" do
    cloth.update!(gender: 'male')
    expect(cloth.reload.gender).to eq 'male'
  end

  it "creates cloth variants" do
    cloth.cloth_variants_configuration = {
      "0" => { "color" => "red", "sizes" => "L,M" },
      "1" => { "color" => "blue", "sizes" => " S, M " },
    }
    cloth.save!
    expect(cloth.cloth_variants.find_by(size: "L", color: "red")).not_to be_nil
    expect(cloth.cloth_variants.find_by(size: "M", color: "red")).not_to be_nil
    expect(cloth.cloth_variants.find_by(size: "S", color: "blue")).not_to be_nil
    expect(cloth.cloth_variants.find_by(size: "M", color: "blue")).not_to be_nil
  end
end
