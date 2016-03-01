class Address < ActiveRecord::Base
  geocoded_by :full_address

  belongs_to :city
  belongs_to :addressable, polymorphic: true

  before_validation :geocode, if: -> {
    address.present? \
    && city.present? \
    && !latitude_changed? \
    && !longitude_changed?
  }
  validates :city, :latitude, :longitude, presence: true

  scope :order_by_distance, -> (location) {
    select("#{table_name}.*")
    .select("(#{distance_from_sql(location)}) as distance")
    .order('distance')
  }

  def full_address
    [address, address_2, city.name, city.state].compact.join(', ')
  end

  def coordinates
    [latitude, longitude]
  end

  rails_admin do
    edit do
      field :address
      field :address_2
      field :city
    end
  end
end
