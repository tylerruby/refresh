class FetchAddress
  CITY_FIELDS = %w(
    locality
    sublocality
    administrative_area_level_3 administrative_area_level_2
  )

  def initialize(address)
    self.address = address
  end

  def city
    @city ||= address_components.detect do |address_component|
      (address_component["types"] & CITY_FIELDS).any?
    end
    @city["long_name"]
  end

  def latitude
    coordinates["lat"]
  end

  def longitude
    coordinates["lng"]
  end

  def formatted_address
    geocoded_address["formatted_address"]
  end

  private

    attr_accessor :address

    def geocoded_address
      @geocoded_address ||= Geocoder.search(address).first.data
    end

    def coordinates
      geocoded_address["geometry"]["location"]
    end

    def address_components
      geocoded_address["address_components"]
    end
end
