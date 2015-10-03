class RenameThumbnailToImageFromStores < ActiveRecord::Migration
  def change
    rename_column :stores, :thumbnail_file_name,    :image_file_name
    rename_column :stores, :thumbnail_content_type, :image_content_type
    rename_column :stores, :thumbnail_file_size,    :image_file_size
    rename_column :stores, :thumbnail_updated_at,   :image_updated_at
    rename_column :stores, :thumbnail_dimensions,   :image_dimensions
  end
end
