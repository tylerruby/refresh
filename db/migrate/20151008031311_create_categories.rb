class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.boolean :male, default: false
      t.boolean :female, default: false

      t.timestamps null: false
    end
  end
end
