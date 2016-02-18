module GeocoderTest
  def stub_address(address, latitude, longitude, city: '')
    Geocoder::Lookup::Test.add_stub(address, [
      {
        'latitude'     => latitude,
        'longitude'    => longitude,
        'address'      => address,
        'state'        => 'Georgia',
        'state_code'   => 'GA',
        'country'      => 'United States',
        'country_code' => 'US',
        'formatted_address' => address,
        'address_components' => [
          {
            "long_name" => city,
            "short_name" => city,
            "types" => ["locality", "political"]
          }
        ],
        'geometry' => {
          'location' => { 'lat' => latitude, 'lng' => longitude }
        }
      }
    ])
  end
end

RSpec.configure do |config|
  config.include GeocoderTest
end
