function FilterClothes () {
  var filterParams = $('[data-filter]').map(extractFilterParam);
  filterParams = Array.prototype.reduce.call(filterParams, buildParams, {});

  var clothesPanel = $('#clothes');
  clothesPanel.html($('.spinner').clone().show());
  $.get('/clothes', filterParams).then(loadClothes);

  function loadClothes (html) {
    clothesPanel.html(html);
    clothesPanel.trigger('page:load');
    bindSliders(clothesPanel);
    bindFilters(clothesPanel);
  }

  function bindFilters (element) {
    element.find('[data-filter] [data-filter-select]').click(bindFilter);

    function bindFilter () {
      var option = $(this);
      var value = option.data('filter-select');
      option
        .closest('[data-filter]')
        .data('filter-value', value);

      FilterClothes();
    }
  }

  function bindSliders (element) {
    element.find('.js-slider')
      .on('input', updateView)
      .on('change', updateValue)
      .trigger('input');

    function updateView () {
      var slider = $(this);
      slider.parent().find('.js-slider-value').html(slider.val());
    }

    function updateValue () {
      var slider = $(this);
      slider.data('filter-value', slider.val());

      FilterClothes();
    }
  }

  function extractFilterParam (_, filter) {
    filter = $(filter);
    var value = filter.data('filter-value');
    if (!!value) {
      return { name: filter.data('filter'), value: value };
    }
  }

  function buildParams (accumulator, param) {
    accumulator[param['name']] = param['value'];
    return accumulator;
  }
}

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
