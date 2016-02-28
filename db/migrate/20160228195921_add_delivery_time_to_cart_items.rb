class AddDeliveryTimeToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :delivery_time, :string, default: '11:30 AM'
  end
end
