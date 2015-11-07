class DropChains < ActiveRecord::Migration
  def change
    drop_table :chains
  end
end
