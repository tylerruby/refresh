function FilterClothes () {
  var filterParams = $('[data-filter]').map(extractFilterParam);
  filterParams = Array.prototype.reduce.call(filterParams, buildParams, {});

  var clothesPanel = $('#clothes');
  clothesPanel.html($('.js-spinner').clone().show());
  $.get('/clothes', filterParams).then(loadClothes);

  function loadClothes (html) {
    clothesPanel.html(html);
    clothesPanel.trigger('page:load');
    var filtersNav = clothesPanel.find('.filters');
    filtersNav = $('.js-filters-nav').html(filtersNav);
    bindSliders(filtersNav);
    bindFilters(filtersNav);
  }

  function bindFilters (element) {
    element.find('[data-filter] [data-filter-select]').click(bindFilter);

    function bindFilter () {
      var option = $(this);
      var value = option.data('filter-select');
      var filter = option.closest('[data-filter]');
      filter.data('filter-value', value);

      triggerResets(filter);
      FilterClothes();
    }

    function triggerResets (filter) {
      if (filter.data('filter') == 'category_id') {
        element.find('[data-filter=size]').data('filter-value', null);
      }
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

