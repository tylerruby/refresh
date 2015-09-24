class RemoveGenderFromClothInstances < ActiveRecord::Migration
  def change
    remove_column :cloth_instances, :gender, :integer
  end
end
