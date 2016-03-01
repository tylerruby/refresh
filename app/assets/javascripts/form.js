$(function setupForms() {
  $('[data-validate]').each(function validate(_, form) {
    $(form).validate();
  });
});
