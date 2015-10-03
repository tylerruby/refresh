class CartItem < ActiveRecord::Base
  acts_as_shopping_cart_item_for :cart

  delegate :name, :color, :size, :gender, :image, :store, to: :item
end
