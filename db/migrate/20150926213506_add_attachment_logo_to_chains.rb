class AddAttachmentLogoToChains < ActiveRecord::Migration
  def self.up
    change_table :chains do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :chains, :logo
  end
end
