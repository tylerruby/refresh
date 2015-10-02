class ReprocessImagesForClothes < ActiveRecord::Migration
  def change
    Cloth.find_each do |cloth|
      puts "Reprocessing image for #{cloth.name}..."
      cloth.image.reprocess! :medium

      if cloth.image.exists?
        puts "Extracting dimensions from image..."
        cloth.extract_from(cloth.image.url(:medium))
        cloth.save!
      end
    end
  end
end
