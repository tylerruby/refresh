(function loadImageGrids () {
  $(document).ready(function bootstrapAndSetEvents () {
    setImageGrids()
    $('a[data-toggle="tab"]').on('shown.bs.tab', setImageGrids);
  });

  function setImageGrids() {
    $('.js-image-grid').removeWhitespace().collagePlus({
      'fadeSpeed' : 100,
      'targetHeight' : 400,
      'allowPartialLastRow': true
    });
  };

  var resizeTimer = null;
  $(window).bind('resize', function() {
    // hide all the images until we resize them
    $('.js-image-grid .item').css("opacity", 1);

    // set a timer to re-apply the plugin
    if (resizeTimer) clearTimeout(resizeTimer);
    resizeTimer = setTimeout(setImageGrids, 100);
  });
})();
