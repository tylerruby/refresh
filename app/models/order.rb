class Order < ActiveRecord::Base
  monetize :amount_cents
  enum status: %w(pending waiting_confirmation on_the_way delivered internal_failure external_failure)

  belongs_to :user
  has_many :cart_items, as: :owner, dependent: :destroy
  validates :user, presence: true
end
