class AddAvailableToProducts < ActiveRecord::Migration
  def change
    add_column :products, :available, :boolean, default: false
  end
end
