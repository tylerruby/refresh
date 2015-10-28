class AddDeliveryTimeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_time, :integer
  end
end
