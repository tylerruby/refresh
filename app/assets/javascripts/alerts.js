$(function () {
  setTimeout(autoclose, 5000);
  function autoclose () {
    $('.alert.autoclose').alert('close');
  }

  function Alert(options) {
    this.element = this.buildElement(options).alert();

    $(document.body).prepend(this.element);

    if (options.autoclose) {
      setTimeout(this.close.bind(this), options.autoclose);
    }
  }

  Alert.prototype.close = function close() {
    this.element.alert('close');
  }

  Alert.prototype.buildElement = function buildElement(options) {
    var classes = "alert side-alert fade in";

    classes += " " + (options.class ? options.class : "alert-info");

    var element = $(
      '<div class="' + classes + '" role="alert">' + options.message + '</div>'
    );

    if (options.closeable) {
      element
        .addClass("alert-dismissible")
        .prepend(
          '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
            '<span aria-hidden="true">&times;</span>' +
          '</button>'
        );
    }

    return element;
  };

  window.Alert = Alert;
});
