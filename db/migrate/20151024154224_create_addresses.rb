class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address
      t.belongs_to :city, index: true, foreign_key: true
      t.references :addressable, polymorphic: true, index: true
      t.float :latitude
      t.float :longitude

      t.timestamps null: false
    end
  end
end
