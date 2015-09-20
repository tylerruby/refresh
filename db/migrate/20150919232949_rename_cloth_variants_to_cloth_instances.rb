class RenameClothVariantsToClothInstances < ActiveRecord::Migration
  def change
    rename_table :cloth_variants, :cloth_instances
  end
end
