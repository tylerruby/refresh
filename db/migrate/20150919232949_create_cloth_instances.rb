class CreateClothInstances < ActiveRecord::Migration
  def change
    create_table :cloth_instances do |t|
      t.string :size
      t.string :color
      t.string :gender
      t.belongs_to :cloth, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
