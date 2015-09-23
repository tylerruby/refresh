require 'rails_helper'

RSpec.describe ClothInstance, type: :model do
  it "must belong to a cloth variant" do
    cloth_instance = ClothInstance.new
    expect(cloth_instance).not_to be_valid
    expect(cloth_instance.errors).to have_key :cloth_variant
  end

  it "must belong to a store" do
    cloth_instance = ClothInstance.new
    expect(cloth_instance).not_to be_valid
    expect(cloth_instance.errors).to have_key :store
  end
end
