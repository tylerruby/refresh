class ClothVariant < ActiveRecord::Base
  belongs_to :cloth
  has_many :cloth_instances
  validates :cloth, presence: true
  delegate :price, :name, :gender, :image, to: :cloth
end
