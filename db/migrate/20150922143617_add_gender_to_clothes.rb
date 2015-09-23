class AddGenderToClothes < ActiveRecord::Migration
  def change
    add_column :clothes, :gender, :integer
  end
end
