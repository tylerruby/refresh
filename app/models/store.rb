class Store < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  RADIUS = 10 # miles
  geocoded_by :full_address
  after_validation :geocode, if: -> { address.present? and address_changed? }

  validates :name, :address, :city, :state, presence: true
  scope :by_city, -> (city) { where('lower(city) = ?', city.downcase) }
  scope :order_by_distance, -> (location) { 
    select("#{table_name}.*")
    .select("(#{distance_from_sql(location)}) as distance")
    .order('distance')
  }

  def full_address
    [address, city, state].join(', ')
  end

  def available_for_delivery?
    distance <= RADIUS
  rescue NameError => e
    # distance is a method defined when making a query with distance 
    # calculation, so it may not be defined if the model was retrived 
    # in another way.
    false
  end

  def slug_candidates
    [
      :name,
      [:name, :city],
      [:name, :city, :state],
      [:name, :city, :state, :id]
    ]
  end
end
