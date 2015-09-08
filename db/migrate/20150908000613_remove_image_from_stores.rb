class RemoveImageFromStores < ActiveRecord::Migration
  def change
    remove_attachment :stores, :image
  end
end
