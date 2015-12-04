class Product < ActiveRecord::Base
  # acts_as_paranoid
  mount_uploader :image, ImageUploader
  monetize :price_cents
  belongs_to :category
  belongs_to :store
  validates :name, presence: true

  scope :available, -> { where(available: true) }

  rails_admin do
    edit do
      field :name
      field :description
      field :price
      field :store
      field :image
      field :available
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
