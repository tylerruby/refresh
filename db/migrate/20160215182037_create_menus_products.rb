class CreateMenusProducts < ActiveRecord::Migration
  def change
    create_table :menus_products do |t|
      t.belongs_to :menu, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
    end
  end
end
