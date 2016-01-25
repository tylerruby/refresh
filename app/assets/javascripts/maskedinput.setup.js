$(function setupMaskedInput() {
  $("[data-phone-number]").each(function maskPhone(_, input) {
    $(input).mask('(999) 999-9999');
  });
});
