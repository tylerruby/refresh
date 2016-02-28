class FetchAddress
  FIELDS = {
    street: %w(route),
    street_number: %w(street_number),
    region: %w(
      sublocality_level_1
      sublocality
      neighborhood
    ),
    city: %w(
      locality
      administrative_area_level_3
      administrative_area_level_2
    ),
    state: %w(administrative_area_level_1),
    country: %w(country)
  }

  def initialize(raw_address)
    self.raw_address = raw_address
  end

  def street
    @street ||= parse_component(:street, "long_name")
  end

  def street_number
    @street_number ||= parse_component(:street_number, "long_name")
  end

  def region
    @region ||= parse_component(:region, "long_name")
  end

  def city
    @city ||= parse_component(:city, "long_name")
  end

  def state
    @state ||= parse_component(:state, "short_name")
  end

  def country
    @country ||= parse_component(:country, "short_name")
  end

  def latitude
    coordinates["lat"]
  end

  def longitude
    coordinates["lng"]
  end

  def address
    [street, street_number].compact.join(" ")
  end

  def formatted_address
    geocoded_address["formatted_address"]
  end

  private

    attr_accessor :raw_address

    def geocoded_address
      @geocoded_address ||= Geocoder.search(raw_address).first.data
    end

    def coordinates
      geocoded_address["geometry"]["location"]
    end

    def address_components
      geocoded_address["address_components"]
    end

    def parse_component(component_fields, format)
      find_component(component_fields).try(:[], format)
    end

    def find_component(component_fields)
      address_components.detect do |address_component|
        (address_component["types"] & FIELDS[component_fields]).any?
      end
    end
end
