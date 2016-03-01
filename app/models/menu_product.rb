class MenuProduct < ActiveRecord::Base
  belongs_to :menu
  belongs_to :product

  delegate :name, :image, :image_url, :description, :restaurant, :price, to: :product
end
