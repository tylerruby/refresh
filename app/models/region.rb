class Region < ActiveRecord::Base
  has_one :address, as: :addressable, dependent: :destroy
  has_many :menus, dependent: :destroy
  validates :address, presence: true
  accepts_nested_attributes_for :address, allow_destroy: true

  rails_admin do
    edit do
      field :name
      field :address
    end
  end
end
