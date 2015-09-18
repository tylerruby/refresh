class RemoveColorFromClothes < ActiveRecord::Migration
  def change
    remove_column :clothes, :color, :string
  end
end
