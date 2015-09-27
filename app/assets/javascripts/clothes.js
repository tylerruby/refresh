(function initializeClothVariantSelection () {
  $(SelectClothVariant);
  $(TrackClothViews);

  function SelectClothVariant () {
    var sizeSelect = $('.js-size-select');
    sizeSelect.change(sizeSelected);
    sizeSelect.trigger('change');

    function generateOptions (clothVariant) {
      return '<option value="' + clothVariant.id + '">' + clothVariant.color + "</option>";
    }

    function sizeSelected () {
      var clothVariants = $(this).find('option:selected').data('cloth-variants');
      var clothVariantSelect = $(this.form).find('.js-color-select');

      var options = clothVariants.map(generateOptions);
      clothVariantSelect.html(options.join(''));
    }
  }

  function TrackClothViews () {
    $('.js-cloth-modal').on('show.bs.modal', track);

    function track (event) {
      var clothId = $(event.target).data('cloth-id');
      $.get('/clothes/' + clothId);
    }
  }
})();
