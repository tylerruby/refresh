class Cloth < ActiveRecord::Base
  monetize :price_cents

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "https://placehold.it/1000x600"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  belongs_to :chain
  has_many :cloth_instances
  validates :name, :chain, presence: true

  def colors=(values)
    values = values.split(',') if values.is_a? String
    write_attribute(:colors, values.map(&:strip))
  end

  rails_admin do
    edit do
      field :name
      field :price
      field :colors do
        help "Optional - Type a list of colors separated by comma. Ex: red, blue"
        formatted_value do
          value.join(', ')
        end
      end
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

      field :colors
      field :image
      field :chain
    end
  end
end
