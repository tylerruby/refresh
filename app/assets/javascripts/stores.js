function initGoogleMapsAutocomplete() {
  // Create the autocomplete object, restricting the search to geographical
  // location types.
  var autocomplete = new google.maps.places.Autocomplete(
      (document.getElementById('gmaps-autocomplete')),
      {types: ['geocode']});

  function placeSelected() {
    submitLocation([autocomplete.getPlace()]);
  }

  var form = $('#store-location-form');
  function submitLocation(places) {
    form.attr('action', getCity(places[0]).replace(' ', '-').toLowerCase()).submit();
  }

  // Shamelessly copied from: https://github.com/alexreisner/geocoder/blob/017e06786c0a89905c50ff3c15bd7090c422a8f8/lib/geocoder/results/google.rb#L20
  function getCity(place) {
    var fields = [
      'locality',
      'sublocality',
      'administrative_area_level_3',
      'administrative_area_level_2'
    ];

    for (var i = 0; i < fields.length; i++) {
      var entity = addressComponentsOfType(fields[i], place)[0];
      if (entity) {
        return entity['long_name'];
      }
    }
    return '';
  }

  function addressComponentsOfType(type, place) {
    return place
      .address_components
      .filter(function filterByType(c) {
        return c.types.indexOf(type) != -1;
      });
  }

  // When the user selects an address from the dropdown, submits the form.
  autocomplete.addListener('place_changed', placeSelected);

  function definedAction() {
    return !!form.attr('action');
  }

  function checkAddressBeforeSubmit(e) {
    if (!definedAction()) {
      e.preventDefault();
      var geocoder = new google.maps.Geocoder();
      var address = form.find('input[name=address]').val();
      geocoder.geocode({ address: address }, submitLocation);
    }
  }

  form.on('submit', checkAddressBeforeSubmit);
}
