require 'rails_helper'

RSpec.describe ClothVariant, type: :model do
  it "only allows male or female genders" do
    cloth_variant = ClothVariant.new
    expect { cloth_variant.gender = 'male' }.not_to raise_error
    expect { cloth_variant.gender = 'female' }.not_to raise_error
    expect { cloth_variant.gender = 'other' }.to raise_error(ArgumentError)
  end

  it "saves the gender to the database" do
    cloth_variant = create(:cloth_variant, gender: 'male')
    expect(cloth_variant.reload.gender).to eq 'male'
  end

  it "must belong to a cloth" do
    cloth_variant = ClothVariant.new
    expect(cloth_variant).not_to be_valid
    expect(cloth_variant.errors).to have_key :cloth
  end
end
