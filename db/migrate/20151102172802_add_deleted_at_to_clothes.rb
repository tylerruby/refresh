class AddDeletedAtToClothes < ActiveRecord::Migration
  def change
    add_column :clothes, :deleted_at, :datetime
    add_index :clothes, :deleted_at
  end
end
