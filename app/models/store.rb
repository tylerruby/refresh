class Store < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  mount_uploader :image, ImageUploader
  mount_uploader :logo, ImageUploader

  RADIUS = 10 # miles
  EXTRA_HOURS = 5
  EXTENDED_DAY_HOURS = 24 + EXTRA_HOURS # To support stores that close after midnight

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

  default_scope -> { order(opens_at: :asc) }
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
    merge_addresses Address.for_stores.near(location, Store::RADIUS)
  end

  def self.opened
    sql = <<-EOS
      (
        opens_at <= :current_time
        AND
        closes_at > :current_time
      ) OR (opens_at IS NULL AND closes_at IS NULL)
    EOS

    where(sql, current_time: current_time_with_extra_hours)
  end

  def self.order_by_distance(location)
    merge_addresses(Address.for_stores.order_by_distance(location))
  end

  def self.merge_addresses(addresses)
    includes(:address)
    .references(:address)
    .merge(addresses)
  end

  def opened?
    return true if opens_at.nil? && closes_at.nil?
    current_time = self.class.current_time_with_extra_hours
    opens_at <= current_time && closes_at > current_time
  end

  def closed?
    !opened?
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
    @human_opens_at ||= TimeOfDay.to_string(opens_at)
  end

  def human_closes_at
    @human_closes_at ||= TimeOfDay.to_string(closes_at)
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

  def parse_working_hours
    return if human_opens_at.blank? || human_closes_at.blank?

    begin
      self.opens_at = TimeOfDay.to_decimal(human_opens_at)
    rescue ArgumentError => e
      self.errors.add(:human_opens_at, :invalid)
    end

    begin
      self.closes_at = TimeOfDay.to_decimal(human_closes_at)
    rescue ArgumentError => e
      self.errors.add(:human_closes_at, :invalid)
    end

    return unless opens_at.present? && closes_at.present?
    # In case of store close after midnight
    if closes_at < opens_at
      self.closes_at = closes_at + 24
    end
  end

  def distance_from_user
    @distance_from_user || distance
  rescue NameError => e
    # distance is a method defined when making a query with distance
    # calculation, so it may not be defined if the model was retrived
    # in another way. In this case, we default to an infinite distance.
    Float::INFINITY
  end

  def self.current_time_with_extra_hours
    current_time = TimeOfDay.to_decimal(Time.current)

    # Support stores that close after midnight
    # For instance, 01:00 AM in real world is 25:00 in our system.
    current_time <= EXTRA_HOURS ? current_time + 24 : current_time
  end
end
