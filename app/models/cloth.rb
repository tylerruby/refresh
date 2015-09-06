class Cloth < ActiveRecord::Base
  monetize :price_cents

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "https://placehold.it/1000x600"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  belongs_to :chain
  validates :name, :price, :chain, presence: true

  rails_admin do
    edit do
      field :name
      field :price
      field :color
      field :image
      field :chain
    end

    list do
      field :name

      field :price do
        pretty_value do
          value.format
        end
      end

      field :color
      field :image
      field :chain
    end
  end

end
