class RemoveDeliveryTimeFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :delivery_time, :integer
  end
end
