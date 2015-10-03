require 'rails_helper'

RSpec.describe CartItem, type: :model do
  it "delegates attributes to item" do
    cloth_instance = create(:cloth_instance)
    cart_item = build(:cart_item, item: cloth_instance)

    %w(name color size gender image store).each do |attribute|
      expect(cart_item.send(attribute)).to eq cloth_instance.send(attribute)
    end
  end
end
