(function initializeClothVariantsGenerator () {
  $(document).on('rails_admin.dom_ready', ClothVariantsGenerator);

  function ClothVariantsGenerator () {
    var i = 0;
    var addColorButton = $('.rails-admin.js-colors').find('.js-add-color');
    addColorButton.click(addColor);

    function addColor () {
      var template = $(buildTemplate(i++));
      $(this).before(template);
      template.find('.js-remove-color').click(function removeColor () {
        template.remove();
      });
    }

    function buildTemplate (id) {
      return baseTemplate.replace(/{{id}}/g, id);
    }

    var baseTemplate =
      '<div class="color">' +
        '<label for="color_{{id}}">Color</label>' +
        '<input id="color_{{id}}" type="text" name="cloth[cloth_variants_configuration][{{id}}][color]" required>' +
        '<label for="size_{{id}}">Sizes</label>' +
        '<input id="size_{{id}}" type="text" name="cloth[cloth_variants_configuration][{{id}}][sizes]" required>' +
        '<a class="js-remove-color" href="javascript:void(0)">Remove color</a>' +
      '</div>';

    addColorButton.click();
  }
})();
