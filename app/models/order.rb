class Order < ActiveRecord::Base
  monetize :amount_cents

  belongs_to :user
  has_many :cart_items, as: :owner
  validates :user, presence: true
end
