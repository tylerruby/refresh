class AddThumbnailDimensionsToStores < ActiveRecord::Migration
  def change
    add_column :stores, :thumbnail_dimensions, :string
  end
end
