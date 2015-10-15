function FilterClothes () {
  var filterParams = $('[data-filter]').map(extractFilterParam);
  filterParams = Array.prototype.reduce.call(filterParams, buildParams, {});

  var clothesPanel = $('#clothes');
  clothesPanel.html($('.js-spinner').clone().show());
  $.get('/clothes', filterParams).then(loadClothes);

  function loadClothes (html) {
    clothesPanel.html(html);
    clothesPanel.trigger('page:load');
    var originalFiltersNav = clothesPanel.find('.filters');
    var newFiltersNav = $('.js-filters-nav').html(originalFiltersNav.html());
    originalFiltersNav.remove();
    bindSliders(newFiltersNav);
    bindFilters(newFiltersNav);
  }

  function bindFilters (element) {
    element
      .find('[data-filter]')
      .on('app.resetSubfilters', resetSubfilters)
      .find('[data-filter-select]')
      .click(selectFilter);

    function selectFilter () {
      var option = $(this);
      var value = option.data('filter-select');
      var filter = option.closest('[data-filter]');
      filter.data('filter-value', value);
      filter.trigger('app.resetSubfilters')

      FilterClothes();
    }

    function resetSubfilters (filter) {
      var filterType = $(this).data('filter');

      if (filterType == 'gender') {
        element
          .find('[data-filter=category_id]')
          .data('filter-value', null)
          .trigger('app.resetSubfilters');
      }

      if (filterType == 'category_id') {
        element
          .find('[data-filter=size]')
          .data('filter-value', null);
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

