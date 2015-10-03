class RenameImagesOnS3ForStores < ActiveRecord::Migration
  def up
    Store.find_each do |store|
      puts "Renaming image for #{store.name}..."
      old_url = store.image.url.gsub /\/stores\/images\//, '/stores/thumbnails/'
      puts "Old url: #{old_url}"
      store.update!(image: old_url)
    end
  end
end
