class AddChainToStores < ActiveRecord::Migration
  def change
    add_reference :stores, :chain, index: true, foreign_key: true
  end
end
