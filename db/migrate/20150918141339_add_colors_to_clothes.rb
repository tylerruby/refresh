class AddColorsToClothes < ActiveRecord::Migration
  def change
    add_column :clothes, :colors, :string, array: true, default: []
  end
end
