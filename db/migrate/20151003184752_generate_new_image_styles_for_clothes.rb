class GenerateNewImageStylesForClothes < ActiveRecord::Migration
  def change
    Cloth.find_each do |cloth|
      puts "Generating image styles for #{cloth.name}..."
      cloth.image.reprocess!

      if cloth.image.exists?
        puts "Extracting dimensions from image..."
        cloth.extract_from(cloth.image.url(:medium))
        cloth.save!
      end
    end
  end
end
