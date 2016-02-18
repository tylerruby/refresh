class AddRegionToMenus < ActiveRecord::Migration
  def change
    add_reference :menus, :region, index: true, foreign_key: true
  end
end
