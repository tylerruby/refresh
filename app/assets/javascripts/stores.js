var autocomplete;

function initGoogleMapsAutocomplete() {
  // Create the autocomplete object, restricting the search to geographical
  // location types.
  autocomplete = new google.maps.places.Autocomplete(
      (document.getElementById('gmaps-autocomplete')),
      {types: ['geocode']});

  // When the user selects an address from the dropdown, populate the address
  // fields in the form.
  autocomplete.addListener('place_changed', fillInAddress);
}

function fillInAddress() {
  var place = autocomplete.getPlace();
  var loc = place.geometry.location;
  setCoordinates(loc.lat(), loc.lng());
  $('#store-location-form').attr('action', '/' + place.vicinity).submit();
}

function setCoordinates(latitude, longitude) {
  $('#latitude').val(latitude);
  $('#longitude').val(longitude);
}
