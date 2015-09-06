class CreateClothes < ActiveRecord::Migration
  def change
    create_table :clothes do |t|
      t.string :name
      t.money :price
      t.belongs_to :chain, index: true, foreign_key: true
      t.string :color

      t.timestamps null: false
    end
  end
end
