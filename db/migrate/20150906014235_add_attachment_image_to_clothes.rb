class AddAttachmentImageToClothes < ActiveRecord::Migration
  def self.up
    change_table :clothes do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :clothes, :image
  end
end
