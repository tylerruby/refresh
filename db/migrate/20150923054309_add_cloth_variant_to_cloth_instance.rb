class AddClothVariantToClothInstance < ActiveRecord::Migration
  def change
    add_reference :cloth_instances, :cloth_variant, index: true, foreign_key: true
  end
end
