class AddAttachmentThumbnailToStores < ActiveRecord::Migration
  def self.up
    change_table :stores do |t|
      t.attachment :thumbnail
    end
  end

  def self.down
    remove_attachment :stores, :thumbnail
  end
end
