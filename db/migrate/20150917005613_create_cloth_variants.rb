class CreateClothVariants < ActiveRecord::Migration
  def change
    create_table :cloth_variants do |t|
      t.belongs_to :cloth, index: true, foreign_key: true
      t.integer :gender
      t.string :size
      t.string :color

      t.timestamps null: false
    end
  end
end
