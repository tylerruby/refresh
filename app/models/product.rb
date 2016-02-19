class Product < ActiveRecord::Base
  # acts_as_paranoid
  mount_uploader :image, ImageUploader
  monetize :price_cents
  belongs_to :category
  belongs_to :store
  has_many :menu_products
  has_many :menus, through: :menu_products
  validates :name, :price, :store, presence: true

  rails_admin do
    edit do
      field :name
      field :restaurant
      field :description
      field :price
      field :store
      field :image
    end

    list do
      field :name
      field :price do
        pretty_value do
          value.format
        end
      end
      field :image
      field :store
    end
  end
end
