class AddAttachmentBackgroundImageToStores < ActiveRecord::Migration
  def self.up
    change_table :stores do |t|
      t.attachment :background_image
    end
  end

  def self.down
    remove_attachment :stores, :background_image
  end
end
