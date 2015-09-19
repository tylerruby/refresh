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
end
