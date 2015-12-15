class RemoveClothInstances < ActiveRecord::Migration
  def change
    drop_table :cloth_instances
  end
end
