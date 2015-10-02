class Cloth < ActiveRecord::Base
  is_impressionable

  monetize :price_cents
  enum gender: %w(male female unisex)

  has_attached_file :image, styles: { medium: "x300>" },
    default_url: "https://placehold.it/1000x600"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  belongs_to :chain
  has_many :cloth_variants, dependent: :destroy
  validates :name, :gender, :price, :chain, presence: true

  attr_accessor :colors, :cloth_variants_configuration, :store

  before_save :extract_dimensions
  serialize :image_dimensions

  after_create do
    next unless cloth_variants_configuration.present?
    cloth_variants_configuration.values.each do |color_sizes|
      color = color_sizes["color"]
      sizes = color_sizes["sizes"].split(',').map(&:strip)

      sizes.each do |size|
        ClothVariant.create!(cloth: self, size: size, color: color)
      end
    end
  end

  def image_url
    image.url(:medium)
  end

  def image_dimensions
    Dimensions.new(*super)
  end

  def extract_dimensions
    tempfile = image.queued_for_write[:medium]
    extract_from(tempfile) unless tempfile.nil?
  end

  def extract_from(file)
    geometry = Paperclip::Geometry.from_file(file)
    self.image_dimensions = [geometry.width.to_i, geometry.height.to_i]
  end

  rails_admin do
    edit do
      field :name
      field :price
      field :gender do
        enum Cloth.genders
      end
      field :cloth_variants_configuration do
        partial :cloth_variants_configuration
        visible do
          bindings[:object].new_record?
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
