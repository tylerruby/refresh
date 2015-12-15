$(function () {
  setTimeout(autoclose, 5000);
  function autoclose () {
    $('.alert.autoclose').alert('close');
  }
});
