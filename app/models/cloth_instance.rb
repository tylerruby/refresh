class ClothInstance < ActiveRecord::Base
  enum gender: %w(male female)
  belongs_to :cloth
  belongs_to :store
  validates :cloth, :store, presence: true
  delegate :price, :name, to: :cloth
end
