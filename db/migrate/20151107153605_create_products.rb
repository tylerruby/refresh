class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.monetize :price
      t.references :category, index: true, foreign_key: true
      t.references :store, index: true, foreign_key: true
      t.string :image

      t.timestamps null: false
    end
  end
end
