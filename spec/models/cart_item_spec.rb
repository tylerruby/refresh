require 'rails_helper'

RSpec.describe CartItem, type: :model do
  it "delegates attributes to item" do
    product = create(:product)
    cart_item = build(:cart_item, item: product)

    %w(name image store).each do |attribute|
      expect(cart_item.send(attribute)).to eq product.send(attribute)
    end
  end
end
