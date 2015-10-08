class AddCategoryToClothes < ActiveRecord::Migration
  def change
    add_reference :clothes, :category, index: true, foreign_key: true
  end
end
