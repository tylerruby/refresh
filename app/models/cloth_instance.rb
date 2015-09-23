class ClothInstance < ActiveRecord::Base
  belongs_to :cloth
  belongs_to :store
  validates :cloth, :store, presence: true
  delegate :price, :name, :gender, to: :cloth
end
