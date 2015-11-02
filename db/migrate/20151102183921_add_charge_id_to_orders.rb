class AddChargeIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :charge_id, :string
  end
end
