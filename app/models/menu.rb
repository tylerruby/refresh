class Menu < ActiveRecord::Base
  has_many :menu_products
  has_many :products, through: :menu_products
end
