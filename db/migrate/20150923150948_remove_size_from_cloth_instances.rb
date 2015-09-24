class RemoveSizeFromClothInstances < ActiveRecord::Migration
  def change
    remove_column :cloth_instances, :size, :string
  end
end
