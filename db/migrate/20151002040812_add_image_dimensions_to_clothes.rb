class AddImageDimensionsToClothes < ActiveRecord::Migration
  def change
    add_column :clothes, :image_dimensions, :string
  end
end
