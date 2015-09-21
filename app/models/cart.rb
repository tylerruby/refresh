class Cart < ActiveRecord::Base
  acts_as_shopping_cart_using :cart_item

  def description
    "#{total_unique_items} #{'cloth'.pluralize(total_unique_items)} (#{total.format})"
  end

  def taxes
    0
  end
end
