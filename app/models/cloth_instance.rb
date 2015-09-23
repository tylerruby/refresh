class ClothInstance < ActiveRecord::Base
  belongs_to :cloth_variant
  belongs_to :store
  validates :cloth_variant, :store, presence: true
  delegate :price, :name, :gender, to: :cloth_variant
end
