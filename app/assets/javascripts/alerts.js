$(function () {
  setTimeout(autoclose, 3000);
  function autoclose () {
    $('.alert.autoclose').alert('close');
  }
});
