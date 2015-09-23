class RemoveColorFromClothInstances < ActiveRecord::Migration
  def change
    remove_column :cloth_instances, :color, :string
  end
end
