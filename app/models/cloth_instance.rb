class ClothInstance < ActiveRecord::Base
  belongs_to :cloth_variant
  belongs_to :store
  validates :cloth_variant, :store, presence: true
  delegate :color, :size, :price, :name, :gender, :image, to: :cloth_variant
end
