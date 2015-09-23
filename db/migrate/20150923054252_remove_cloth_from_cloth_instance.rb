class RemoveClothFromClothInstance < ActiveRecord::Migration
  def change
    remove_reference :cloth_instances, :cloth, index: true, foreign_key: true
  end
end
