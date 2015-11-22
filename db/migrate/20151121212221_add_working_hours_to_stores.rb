class AddWorkingHoursToStores < ActiveRecord::Migration
  def change
    add_column :stores, :opens_at, :decimal, precision: 17, scale: 15
    add_column :stores, :closes_at, :decimal, precision: 17, scale: 15
  end
end
