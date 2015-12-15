module GeocoderTest
  def stub_address(address, latitude, longitude)
    Geocoder::Lookup::Test.add_stub(address, [
      {
        'latitude'     => latitude,
        'longitude'    => longitude,
        'address'      => address,
        'state'        => 'Georgia',
        'state_code'   => 'GA',
        'country'      => 'United States',
        'country_code' => 'US'
      }
    ])
  end
end

RSpec.configure do |config|
  config.include GeocoderTest
end
