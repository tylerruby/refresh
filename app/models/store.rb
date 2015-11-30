class Store < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  mount_uploader :image, ImageUploader
  mount_uploader :logo, ImageUploader

  RADIUS = 10 # miles
  EXTENDED_DAY_HOURS = 29 # To support stores that close after midnight

  has_many :products
  has_one :address, as: :addressable, dependent: :destroy

  validates :address, presence: true
  validates :opens_at, inclusion: {in: 0..24}, allow_nil: true
  validates :closes_at, inclusion: {in: 0..EXTENDED_DAY_HOURS}, allow_nil: true
  validates :opens_at, presence: true, if: 'human_closes_at.present? || closes_at.present?'
  validates :closes_at, presence: true, if: 'human_opens_at.present? || opens_at.present?'

  before_validation :parse_working_hours, if: 'human_opens_at && human_closes_at'

  delegate :full_address, :coordinates, to: :address

  attr_writer :distance_from_user, :human_opens_at, :human_closes_at

  accepts_nested_attributes_for :address, allow_destroy: true

  scope :by_city, -> (city) {
    joins(address: :city)
    .where('lower(cities.name) = ?', city.downcase)
  }

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
      field :logo

      field(:human_opens_at) { help 'Optional. Ex.: 09:30' }
      field(:human_closes_at) { help 'Optional. Ex.: 22:30' }
    end

    list do
      field :name
      field :full_address
      field :image
    end
  end

  def self.available_for_delivery(location)
    opened.merge_addresses Address.for_stores.near(location, Store::RADIUS)
  end

  def self.opened
    current_hour = extract_decimal_hour Time.now

    # Support stores that close after midnight
    # For instance, 01:00 AM in real world is 25:00 in our system.
    if current_hour <= EXTENDED_DAY_HOURS - 24
      current_hour = current_hour + 24
    end

    where <<-EOS
      (
        (opens_at BETWEEN 0 AND #{current_hour})
        AND
        (closes_at BETWEEN #{current_hour} AND #{EXTENDED_DAY_HOURS})
      ) OR (opens_at IS NULL AND closes_at IS NULL)
    EOS
  end

  def self.order_by_distance(location)
    merge_addresses(Address.for_stores.order_by_distance(location))
  end

  def self.merge_addresses(addresses)
    includes(:address)
    .references(:address)
    .merge(addresses)
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

  def human_opens_at
    @human_opens_at ||= format_working_hour opens_at
  end

  def human_closes_at
    @human_closes_at ||= format_working_hour closes_at
  end

  # Due to Rails Admin setting the slug to empty string
  def slug=(value)
    super if value.present?
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

  def self.extract_decimal_hour time
    # Creating a BigDecimal manually because Rails accessor is assigning wrong value.
    BigDecimal.new((time.hour + (time.min.to_f / 60)).to_s)
  end

  def extract_decimal_hour time
    self.class.extract_decimal_hour(time)
  end

  def parse_working_hours
    return if human_opens_at.blank? || human_closes_at.blank?

    begin
      self.opens_at = extract_decimal_hour Time.parse(human_opens_at)
    rescue ArgumentError => e
      self.errors.add(:human_opens_at, :invalid)
    end

    begin
      self.closes_at = extract_decimal_hour Time.parse(human_closes_at)
    rescue ArgumentError => e
      self.errors.add(:human_closes_at, :invalid)
    end

    # In case of store close after midnight
    if closes_at < opens_at
      self.closes_at = closes_at + 24
    end
  end

  def format_working_hour working_hour
    return nil unless working_hour
    time = Time.new(2000) + working_hour.hour
    time.strftime '%H:%M'
  end

  def distance_from_user
    @distance_from_user || distance
  rescue NameError => e
    # distance is a method defined when making a query with distance
    # calculation, so it may not be defined if the model was retrived
    # in another way. In this case, we default to an infinite distance.
    Float::INFINITY
  end
end
