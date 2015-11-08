class ReplacePaperclipByCarrierwaveFromStores < ActiveRecord::Migration
  def change
    add_column :stores, :image, :string
    remove_column :stores, :image_file_name, :string
    remove_column :stores, :image_content_type, :string
    remove_column :stores, :image_file_size, :integer
    remove_column :stores, :image_updated_at, :datetime
    remove_column :stores, :image_dimensions, :string
  end
end

