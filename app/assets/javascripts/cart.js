$(function setupCart() {
  $('.new_cart_item').submit(addAsync);
  var cart = $('.cart');
  var cartIcon = $('.cart-icon');
  var cartIconCount = cartIcon.find('.badge');
  setupBindings(cart);

  function setupBindings(cart) {
    cart.find('form:has(.remove-item-button)').submit(removeAsync);
  }

  function showErrorMessage(message) {
    return function delayedFailureMessage() {
      new Alert({
        message: message,
        closeable: true,
        class: "alert-danger"
      });
    };
  }

  function updateCart(message) {
    return function delayedUpdateCart(cartHtml) {
      cart.html(cartHtml);
      var cartItemsCount = cart.find('.cart-item').length;
      cartIconCount.text(cartItemsCount);
      if (cartItemsCount == 0) {
        cartIcon.addClass("hide");
      } else {
        cartIcon.removeClass("hide");
      }
      setupBindings(cart);
      new Alert({
        message: message,
        closeable: true,
        autoclose: 1000
      });
    };
  }

  function asyncSubmit(ev, form, method, successMessage, errorMessage) {
    ev.preventDefault();

    $.ajax({
      url: form.attr("action"),
      method: method,
      data: form.serialize(),
      dataType: "html"
    })
    .done(updateCart(successMessage))
    .fail(showErrorMessage(errorMessage));
  }

  function addAsync(ev) {
    asyncSubmit(
      ev,
      $(this),
      "PATCH",
      "Item added to the cart!",
      "There was a problem adding the item to the cart."
    );
  }

  function removeAsync(ev) {
    asyncSubmit(
      ev,
      $(this),
      "DELETE",
      "Item removed from the cart!",
      "There was a problem removing the item from the cart."
    );
  }
});
