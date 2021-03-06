class Store < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_attached_file :image, styles: { medium: "x300>", thumb: "100x100>" },
    default_url: "https://placehold.it/300x300"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  RADIUS = 10 # miles

  belongs_to :chain
  has_many :clothes, through: :chain
  has_one :address, as: :addressable, dependent: :destroy

  serialize :image_dimensions

  before_save :extract_dimensions

  validates :address, :chain, presence: true

  delegate :logo, to: :chain
  delegate :full_address, :coordinates, to: :address

  attr_writer :distance_from_user

  accepts_nested_attributes_for :address, allow_destroy: true

  scope :by_city, -> (city) {
    joins(address: :city)
    .where('lower(cities.name) = ?', city.downcase)
  }

  def self.available_for_delivery(location)
    merge_addresses(Address.for_stores.near(location, Store::RADIUS))
  end

  def self.order_by_distance(location)
    merge_addresses(Address.for_stores.order_by_distance(location))
  end

  def self.merge_addresses(addresses)
    includes(:address)
    .references(:address)
    .merge(addresses)
  end

  def name
    super.present? ? super : chain.try(:name)
  end

  def available_for_delivery?
    distance_from_user <= RADIUS
  end

  def available_for_delivery_on?(location)
    address.distance_from(location) <= RADIUS
  end

  def slug_candidates
    # TODO: Define a better logic for generating slugs
    [
      :name
    ]
  end

  # Due to Rails Admin setting the slug to empty string
  def slug=(value)
    if value.present?
      write_attribute(:slug, value)
    end
  end

  rails_admin do
    edit do
      field :name do
        help "Optional - Will override the chain's name"
      end

      field :slug do
        help "Optional - It'll be generated when the record is saved. It's the name that appears in the URL."
      end

      field :address
      field :image
      field :chain
    end

    list do
      field :name
      field :chain
      field :full_address
      field :image
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

  def set_distance_from_user!(location)
    self.distance_from_user = address.distance_from(location)
  end

  # TODO: Remove after migrating data
  def city
    raise "Deprecated, please use Address model"
  end

  def city=(_)
    raise "Deprecated, please use Address model"
  end

  def state
    raise "Deprecated, please use Address model"
  end

  def state=(_)
    raise "Deprecated, please use Address model"
  end

  def latitude
    raise "Deprecated, please use Address model"
  end

  def latitude=(_)
    raise "Deprecated, please use Address model"
  end

  def longitude
    raise "Deprecated, please use Address model"
  end

  def longitude=(_)
    raise "Deprecated, please use Address model"
  end

  private

  def distance_from_user
    @distance_from_user || distance
  rescue NameError => e
    # distance is a method defined when making a query with distance
    # calculation, so it may not be defined if the model was retrived
    # in another way. In this case, we default to an infinite distance.
    Float::INFINITY
  end
end
