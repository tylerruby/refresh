class RemoveStoreFromProducts < ActiveRecord::Migration
  def change
    remove_reference :products, :store, index: true, foreign_key: true
  end
end
