class Menu < ActiveRecord::Base
  has_many :menu_products
  has_many :products, through: :menu_products
  belongs_to :region

  validates :region, presence: true
  validates :date, uniqueness: { scope: :region_id }
end
