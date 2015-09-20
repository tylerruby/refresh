$(function () {
  setTimeout(autoclose, 1000);
  function autoclose () {
    $('.alert.autoclose').alert('close');
  }
});
