class AddStoreToClothInstance < ActiveRecord::Migration
  def change
    add_reference :cloth_instances, :store, index: true, foreign_key: true
  end
end
