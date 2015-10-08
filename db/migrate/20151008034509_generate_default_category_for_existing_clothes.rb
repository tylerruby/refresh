class GenerateDefaultCategoryForExistingClothes < ActiveRecord::Migration
  def up
    category = Category.create!(name: 'T-Shirts', male: true, female: true)
    Cloth.find_each do |cloth|
      cloth.update!(category: category)
    end
  end
end
