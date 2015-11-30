class RemoveChainFromStores < ActiveRecord::Migration
  def change
    remove_reference :stores, :chain, index: true, foreign_key: true
  end
end
