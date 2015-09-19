require 'rails_helper'

RSpec.describe ClothInstance, type: :model do
  it "only allows male or female genders" do
    cloth_instance = ClothInstance.new
    expect { cloth_instance.gender = 'male' }.not_to raise_error
    expect { cloth_instance.gender = 'female' }.not_to raise_error
    expect { cloth_instance.gender = 'other' }.to raise_error(ArgumentError)
  end

  it "saves the gender to the database" do
    cloth_instance = create(:cloth_instance, gender: 'male')
    expect(cloth_instance.reload.gender).to eq 'male'
  end

  it "must belong to a cloth" do
    cloth_instance = ClothInstance.new
    expect(cloth_instance).not_to be_valid
    expect(cloth_instance.errors).to have_key :cloth
  end
end
