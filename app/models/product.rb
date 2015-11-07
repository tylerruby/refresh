class Product < ActiveRecord::Base
  # acts_as_paranoid
  monetize :price_cents
  belongs_to :category
  belongs_to :store
end
