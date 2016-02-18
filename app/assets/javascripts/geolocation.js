function PlaceWrapper(place) {
  var that = this;

  this.hasAddress = function hasAddress() {
    return !!place.address_components;
  };

  this.getCity = function getCity() {
    for (var i = 0; i < cityFields.length; i++) {
      var entity = addressComponentsOfType(cityFields[i], place)[0];
      if (entity) {
        return entity['long_name'];
      }
    }
    return '';
  };

  this.getLatitude = function getLatitude() {
    return place.geometry.location.lat();
  };

  this.getLongitude = function getLongitude() {
    return place.geometry.location.lng();
  };

  this.getAddress = function getAddress() {
    return place.formatted_address;
  }

  this.getShortAddress = function getShortAddress() {
      var name = place.name;
      name = name.replace(/ (NE|NW|SE|SW)/g, '');
      return name + ", " + place.vicinity;
  }

  // Shamelessly copied from: https://github.com/alexreisner/geocoder/blob/017e06786c0a89905c50ff3c15bd7090c422a8f8/lib/geocoder/results/google.rb#L20
  var cityFields = [
    'locality',
    'sublocality',
    'administrative_area_level_3',
    'administrative_area_level_2'
  ];

  function addressComponentsOfType(type) {
    return place
      .address_components
      .filter(function filterByType(c) {
        return c.types.indexOf(type) != -1;
      });
  }
}

function AddressSelector(form) {
  var that = this;

  function parameterize(name) {
    return name.replace(' ', '-').toLowerCase();
  }

  this.submitLocation = function submitLocation(places) {
    var place = new PlaceWrapper(places[0]);
    if (!place.hasAddress()) {
      return;
    }
    form.find('input[name=latitude]').val(place.getLatitude());
    form.find('input[name=longitude]').val(place.getLongitude());
    form.find('input[name=address]').val(place.getShortAddress());
    form.submit();
  };
}

// This function is called when the Google Maps API finishes initializing.
// Check the app/views/pages/landing.html.erb page.
function initGoogleMapsAutocomplete() {
  // Create the autocomplete object, restricting the search to geographical
  // location types.
  var autocomplete = new google.maps.places.Autocomplete(
      document.getElementById('gmaps-autocomplete'),
      { types: ['geocode', 'establishment'] }
  );

  var addressSelector = new AddressSelector($('#store-location-form'));

  function placeSelected() {
    addressSelector.submitLocation([autocomplete.getPlace()]);
  }

  // When the user selects an address from the dropdown, submits the form.
  autocomplete.addListener('place_changed', placeSelected);
}
