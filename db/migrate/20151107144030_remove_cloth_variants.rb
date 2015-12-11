class RemoveClothVariants < ActiveRecord::Migration
  def change
    drop_table :cloth_variants
  end
end
