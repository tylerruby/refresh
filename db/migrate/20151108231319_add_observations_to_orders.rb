class AddObservationsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :observations, :text
  end
end
