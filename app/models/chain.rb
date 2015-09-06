class Chain < ActiveRecord::Base
  has_many :stores
  validates :name, presence: true
end
