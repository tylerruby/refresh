class RemoveClothes < ActiveRecord::Migration
  def change
    drop_table :clothes
  end
end
