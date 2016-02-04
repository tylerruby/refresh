$(function setupCart() {
  $('.new_cart_item').submit(submitAsync);
  var cart = $('.cart');
  var cartItemsCount = $('.cart-icon .badge');

  function submitAsync(ev) {
    ev.preventDefault();

    $.ajax({
      url: "/cart/add",
      method: "PATCH",
      data: $(this).serialize(),
      dataType: "html",
    }).done(itemAdded).fail(failedToAddItem);
  }

  function itemAdded(cartHtml) {
    cart.html(cartHtml);
    cartItemsCount.text(cart.find('.cart-item').length);
    new Alert({
      message: "Item added to the cart!",
      closeable: true,
      autoclose: 1000
    });
  }

  function failedToAddItem() {
    new Alert({
      message: "There was a problem adding the item to the cart.",
      closeable: true,
      class: "alert-danger"
    });
  }
});
