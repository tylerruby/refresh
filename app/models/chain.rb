class Chain < ActiveRecord::Base
  has_many :stores, dependent: :destroy
  has_many :clothes, dependent: :destroy
  validates :name, presence: true
end
