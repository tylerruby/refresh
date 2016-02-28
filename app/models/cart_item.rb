class CartItem < ActiveRecord::Base
  acts_as_shopping_cart_item_for :cart

  DELIVERY_TIMES = [
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM'
  ]

  belongs_to :menu_product, -> { where('cart_items.item_type': 'MenuProduct') }, foreign_key: :item_id
  validates :delivery_time, inclusion: { in: DELIVERY_TIMES }

  delegate :name, :image, to: :item
end
