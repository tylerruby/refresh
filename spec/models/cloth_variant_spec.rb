require 'rails_helper'

RSpec.describe ClothVariant, type: :model do
  let(:cloth_variant) { build(:cloth_variant) }

  it "isn't really deleted" do
    cloth_variant.save!
    cloth_variant.destroy
    expect(ClothVariant.with_deleted).to include cloth_variant
  end

  it "can be destroyed even if it's related to an order" do
    cloth_instance = create(:cloth_instance, cloth_variant: cloth_variant)
    cart = create(:cart)
    cart.add(cloth_instance, 1)
    order = create(:order)
    order.update!(cart_items: cart.shopping_cart_items)
    cart.reload.destroy!

    expect { cloth_variant.destroy! }.not_to raise_error
  end
end
