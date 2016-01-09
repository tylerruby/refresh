$(function setupRegistrations() {
  setupRemoteForm($('#sign-in-form'), "The email or password is incorrect.");
  setupRemoteForm($('#sign-up-form'), "There was an error in the sign up.");

  function setupRemoteForm(form, errorMessage) {
    form.validate();

    var errorsContainer = form.find('.errors');
    errorsContainer.hide();
    form.submit(submitAndCheckErrors);

    function submitAndCheckErrors() {
      errorsContainer.hide();
      $.ajax({
        url: form.attr('action'),
        method: 'POST',
        data: form.serialize(),
      }).success(refreshPage)
        .error(showErrors);
      return false;
    }

    function refreshPage() {
      window.location.reload();
    }

    function showErrors() {
      errorsContainer
        .html(errorMessage)
        .show();
    }
  }
});
