class Store < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_attached_file :image, styles: { medium: "x300>", thumb: "100x100>" },
    default_url: "https://placehold.it/300x300"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  RADIUS = 10 # miles
  geocoded_by :full_address

  belongs_to :chain
  has_many :clothes, through: :chain
  before_save :extract_dimensions
  serialize :image_dimensions

  before_validation :geocode, if: -> { address.present? and address_changed? }

  validate :validate_geolocation
  validates :address, :city, :state, :chain, presence: true

  delegate :logo, to: :chain

  scope :by_city, -> (city) { where('lower(city) = ?', city.downcase) }
  scope :order_by_distance, -> (location) { 
    select("#{table_name}.*")
    .select("(#{distance_from_sql(location)}) as distance")
    .order('distance')
  }

  def name
    super.present? ? super : chain.try(:name)
  end

  def full_address
    [address, city, state].join(', ')
  end

  def available_for_delivery?
    distance_from_user <= RADIUS
  end

  def slug_candidates
    [
      :name,
      [:name, :city],
      [:name, :city, :state],
      [:name, :city, :state, :id]
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
      field :city
      field :state
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

  private

  def distance_from_user
    distance
  rescue NameError => e
    # distance is a method defined when making a query with distance
    # calculation, so it may not be defined if the model was retrived
    # in another way. In this case, we default to an infinite distance.
    Float::INFINITY
  end

  def validate_geolocation
    return if latitude && longitude
    message = "There was an error when trying to fetch the geolocation for this store. Please try again."
    errors.add(:latitude, message)
    errors.add(:longitude, message)
  end
end
