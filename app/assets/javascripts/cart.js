$(function setupCart() {
  $('.new_cart_item').submit(addAsync);
  $('.delete-form .button_to').submit(function(ev) { updateQuantityAsync(ev, true) });
  var cart = $('.cart');
  var cartIconMenu = $('.cart-icon-menu');
  var drawer = $('.drawer');
  setupDrawer({ showOverlay: true });
  setupBindings(cart);

  function close() {
    drawer.drawer('close');
  }

  function setupDrawer(options) {
    options = $.extend( {
      class: {
        nav: 'list-wrapper'
      },
      showOverlay: false
    }, options);
    drawer.drawer('destroy');
    drawer.drawer(options);
  }

  function setupBindings(cart) {
    setupDrawer();
    cart.find('.close').click(function closeCart() {
      close();
    });
    cart.find('form:has(.remove-item-button)').submit(removeAsync);
    cart.find('form:has(.update-quantity)').submit(updateQuantityAsync);

    var cartItemsCount = calculateCartItemsCount(cart.find('.cart-item .quantity'));
    $('.cart-icon .badge, .cart-items-quantity').text(cartItemsCount);
    if (cartItemsCount == 0) {
      $('.remove-item-button').addClass('hide');
      cartIconMenu.addClass("hide");
      close();
    } else {
      $('.remove-item-button').removeClass('hide');
      cartIconMenu.removeClass("hide");
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

  function updateCart(message, form) {
    var id = $(form).find('#cart_item_menu_product_id').val();

    if (!id) {
      id = $(form).find('#cart_remove_menu_product_id').val();
    }

    var div;

    if (id) {
      div = $('#info-' + id);
    }

    return function delayedUpdateCart(cartHtml) {
      cart.html(cartHtml);
      setupBindings(cart);
      if (div && div.length) {
        div[0].style.display = 'block';
      }
      else {
        new Alert({
          message: message,
          closeable: true,
          autoclose: 1000
        });
      }
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

  function update_remove_form(form, action) {
    var id = $(form).find('#cart_item_menu_product_id').val() || $(form).find('#cart_remove_menu_product_id').val() || $(form).find('.remove-item-button').attr('data-for');

    if (!id) {
      return;
    }

    var rmDiv = $('#rm-' + id);

    if (!rmDiv.length) {
      return;
    }

    var form = rmDiv[0].getElementsByTagName('form')[0];

    if (!form) {
      return;
    }

    var act = $(form).attr('action');

    if (!act) {
      return;
    }

    var qty = act.match(/quantity=(-?\d+)/);

    if (!qty || !qty[1]) {
      return;
    }

    qty = parseInt(qty[1]);

    if (action === 'increase') {
      $(form).attr('action', act.replace(/quantity=(-?\d+)/,'quantity=' +  (qty+1)));
      qty += 2;
    } else if (action === 'decrease') {
        $(form).attr('action', act.replace(/quantity=(-?\d+)/,'quantity=' +  (qty-1)));
    } else if (action === 'zero') {
      $(form).attr('action', act.replace(/quantity=(-?\d+)/,'quantity=0'));
    }

    var infoDiv = $('#info-' + id);

    if (infoDiv.length != 0) {
        infoDiv.html(action === 'zero' ? 0 : qty);
    }
    if (action === 0 || qty === 0) {
      rmDiv[0].style.display = 'none';
    } else {
      rmDiv[0].style.display = '';
    }
  }

  function asyncSubmit(ev, form, method, successMessage, errorMessage) {
    ev.preventDefault();

    $.ajax({
      url: form.attr("action"),
      method: method,
      data: form.serialize(),
      dataType: "html"
    })
    .done(updateCart(successMessage, form))
    .fail(showErrorMessage(errorMessage));
  }

  function addAsync(ev) {
    update_remove_form(this, 'increase');

    asyncSubmit(
      ev,
      $(this),
      "PATCH",
      "Item added to the cart!",
      "There was a problem adding the item to the cart."
    );
  }

  function removeAsync(ev) {
    update_remove_form(this, 'zero');

    asyncSubmit(
      ev,
      $(this),
      "DELETE",
      "Item removed from the cart!",
      "There was a problem removing the item from the cart."
    );
  }

  function updateQuantityAsync(ev, rm) {
    var form = ev.target;

    asyncSubmit(
      ev,
      $(form),
      "PATCH",
      "Item quantity updated!",
      "There was a problem updating the item's quantity."
    );
    if (rm) {
      update_remove_form(form, 'decrease');
    }


  }
});
