class AddAddress2ToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :address_2, :string
  end
end
