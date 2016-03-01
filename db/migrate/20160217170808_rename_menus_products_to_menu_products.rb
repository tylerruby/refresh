class RenameMenusProductsToMenuProducts < ActiveRecord::Migration
  def change
    rename_table :menus_products, :menu_products
  end
end
