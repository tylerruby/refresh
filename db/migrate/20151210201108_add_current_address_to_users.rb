class AddCurrentAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_address_id, :integer, index: true
  end
end
