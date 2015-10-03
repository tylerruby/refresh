(function loadAffix () {
  $(setupAffixes);

  function setupAffixes () {
    var appNavbar = $('#app-navbar');

    $('.js-affix').each(function setupAffix () {
      var $this = $(this);

      $this.affix({
        offset: {
          top: $this.offset().top - appNavbar.height()
        }
      });

      $this.parent('.js-affix-wrapper').height($this.height());
    });
  }
})();
