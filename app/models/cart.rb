class Cart < ActiveRecord::Base
  FEE_RATE = 0.15
  EXTRA_STORE_FEE  = '$3.00'.to_money
  LOW_SUBTOTAL_FEE = '$4.00'.to_money

  class InvalidDeliveryTime < StandardError; end

  acts_as_shopping_cart_using :cart_item

  def description
    "#{total_unique_items} #{'cloth'.pluralize(total_unique_items)} (#{total.format})"
  end

  def taxes
    0
  end

  def shipping_cost_for(delivery_time)
    raise InvalidDeliveryTime, 'Delivery time must be 1 or 2' unless [1, 2].include? delivery_time
    subtotal * FEE_RATE               \
    + shipping_fee_for(delivery_time) \
    + subtotal_fee                    \
    + EXTRA_STORE_FEE * extra_stores
  end

  private

    def shipping_fee_for(delivery_time)
      if delivery_time == 1
        '$5.99'.to_money
      elsif delivery_time == 2
        '$3.99'.to_money
      end
    end

    def subtotal_fee
      subtotal >= 35 ? 0 : LOW_SUBTOTAL_FEE
    end

    def extra_stores
      stores.count - 1
    end

    def stores
      shopping_cart_items
      .map(&:item)
      .map(&:store)
      .uniq
    end
end
