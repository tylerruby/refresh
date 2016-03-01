class CartPolicy < ApplicationPolicy
  def checkout?
    record
      .shopping_cart_items
      .group_by { |cart_item| cart_item.item.menu.date }
      .none? { |date, cart_items| cart_items.to_a.sum(&:quantity) < 3 }
  end
end
