(function initializeClothVariantSelection () {
  $(SelectClothVariant);

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
})();
