class GenerateNewImageStylesForStores < ActiveRecord::Migration
  def up
    Store.find_each do |store|
      puts "Generating image styles for #{store.name}..."
      store.image.reprocess!

      if store.image.exists?
        puts "Extracting dimensions from image..."
        store.extract_from(store.image.url(:medium))
        store.save!
      end
    end
  end
end
