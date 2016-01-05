$(function setupSignIn() {
  var signInForm = $('#sign-in-form');
  var signInErrors = signInForm.find('.errors');
  signInErrors.hide();
  signInForm.submit(submitAndCheckErrors);

  function submitAndCheckErrors() {
    signInErrors.hide();
    $.ajax({
      url: signInForm.attr('action'),
      method: 'POST',
      data: signInForm.serialize(),
    }).success(refreshPage)
      .error(showErrors);
    return false;
  }

  function refreshPage() {
    window.location.reload();
  }

  function showErrors() {
    signInErrors
      .html("The email or password is incorrect.")
      .show();
  }
});
