class AddRestaurantToProducts < ActiveRecord::Migration
  def change
    add_column :products, :restaurant, :string
  end
end
