class AddDeletedAtToClothVariants < ActiveRecord::Migration
  def change
    add_column :cloth_variants, :deleted_at, :datetime
    add_index :cloth_variants, :deleted_at
  end
end
