require 'rails_helper'

describe CartPolicy do
  subject { described_class }

  let(:item_from_today) do
    create :cart_item,
           item: create(:menu_product, menu: create(:menu, date: Date.current))
  end
  let(:item_with_quantity_3_from_today) do
    create :cart_item,
           item: create(:menu_product, menu: create(:menu, date: Date.current)),
           quantity: 3
  end
  let(:item_from_tomorrow) do
    create :cart_item,
           item: create(:menu_product, menu: create(:menu, date: Date.tomorrow))
  end
  let(:cart) do
    create :cart, shopping_cart_items: 3.times.map { item_from_today.dup }
  end
  let(:cart_with_less_than_3_items_per_date) do
    create :cart, shopping_cart_items: [
      item_from_today.dup,
      item_from_tomorrow.dup,
      item_from_tomorrow.dup
    ]
  end
  let(:cart_with_3_of_the_same_item) do
    create :cart, shopping_cart_items: [item_with_quantity_3_from_today.dup]
  end

  permissions :checkout? do
    it { is_expected.to permit(nil, cart) }
    it { is_expected.not_to permit(nil, cart_with_less_than_3_items_per_date) }
    it { is_expected.to permit(nil, cart_with_3_of_the_same_item) }
  end
end
