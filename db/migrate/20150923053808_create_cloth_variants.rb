class CreateClothVariants < ActiveRecord::Migration
  def change
    create_table :cloth_variants do |t|
      t.string :size
      t.string :color
      t.belongs_to :cloth, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
