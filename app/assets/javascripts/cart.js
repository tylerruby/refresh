$(function setupCart() {
  $('.new_cart_item').submit(addAsync);
  var cart = $('.cart');
  var cartIcon = $('.cart-icon');
  var drawer = $('.drawer');
  setupBindings(cart);

  function setupBindings(cart) {
    cart.find('.close').click(function closeCart() {
      drawer.drawer('close');
    });
    cart.find('form:has(.remove-item-button)').submit(removeAsync);
    cart.find('form:has(.update-quantity)').submit(updateQuantityAsync);

    var cartItemsCount = calculateCartItemsCount(cart.find('.cart-item .quantity'));
    $('.cart-icon .badge, .cart-items-quantity').text(cartItemsCount);
    if (cartItemsCount == 0) {
      cartIcon.addClass("hide");
    } else {
      cartIcon.removeClass("hide");
    }
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
      setupBindings(cart);
      new Alert({
        message: message,
        closeable: true,
        autoclose: 1000
      });
    };
  }

  function calculateCartItemsCount(cartItems) {
    return cartItems
      .toArray()
      .map(getInt)
      .reduce(sum, 0);

    function getInt(element) {
      return parseInt(element.textContent);
    }

    function sum(acc, x) { return acc + x; }
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

  function updateQuantityAsync(ev) {
    asyncSubmit(
      ev,
      $(this),
      "PATCH",
      "Item quantity updated!",
      "There was a problem updating the item's quantity."
    );
  }
});
