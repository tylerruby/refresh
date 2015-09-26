class RemoveBackgroundImageFromStores < ActiveRecord::Migration
  def self.up
    remove_attachment :stores, :background_image
  end

  def self.down
    change_table :stores do |t|
      t.attachment :background_image
    end
  end
end
