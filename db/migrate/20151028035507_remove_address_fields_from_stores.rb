class RemoveAddressFieldsFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :address, :string
    remove_column :stores, :city, :string
    remove_column :stores, :state, :string
    remove_column :stores, :latitude, :float
    remove_column :stores, :longitude, :float
  end
end
