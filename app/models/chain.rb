class Chain < ActiveRecord::Base
  has_many :stores
  has_many :clothes
  validates :name, presence: true
end
