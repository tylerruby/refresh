class ClothInstance < ActiveRecord::Base
  enum gender: %w(male female)
  belongs_to :cloth
  validates :cloth, presence: true
end
