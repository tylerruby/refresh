class RemoveCategoryFromProducts < ActiveRecord::Migration
  def change
    remove_reference :products, :category, index: true, foreign_key: true
  end
end
