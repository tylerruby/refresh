class ReprocessThumbnailForStores < ActiveRecord::Migration
  def up
    Store.find_each do |store|
      puts "Reprocessing thumbnail for #{store.name}..."
      store.thumbnail.reprocess! :medium

      if store.thumbnail.exists?
        puts "Extracting dimensions from thumbnail..."
        store.extract_from(store.thumbnail.url(:medium))
        store.save!
      end
    end
  end
end
