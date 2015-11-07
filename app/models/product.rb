class Product < ActiveRecord::Base
  # acts_as_paranoid
  mount_uploader :image, ImageUploader
  monetize :price_cents
  belongs_to :category
  belongs_to :store
  validates :name, presence: true
end
