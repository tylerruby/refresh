class Cart < ActiveRecord::Base
  EXTRA_STORE_FEE  = '$3.00'.to_money
  LOW_SUBTOTAL_FEE = '$4.00'.to_money

  class InvalidDeliveryTime < StandardError; end

  acts_as_shopping_cart_using :cart_item
  attr_accessor :delivery_time

  def description
    "#{total_unique_items} #{'cloth'.pluralize(total_unique_items)} (#{total.format})"
  end

  def taxes
    0
  end

  def shipping_cost
    0
  end
end
