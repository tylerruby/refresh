class AddIndexToMenus < ActiveRecord::Migration
  def change
    add_index :menus, [:date, :region_id], unique: true
  end
end
