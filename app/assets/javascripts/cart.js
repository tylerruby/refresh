$(function setupCart() {
  var cart, cartIconMenu, drawer, productCards, checkoutButton;

  function ProductCard(el, cartDrawer) {
    this.el            = el;
    this.menuProductId = this.el.data('menuProductId');
    this.addForm       = this.el.find('form.new_cart_item');
    this.addBtn        = this.el.find('.add-item-button');
    this.rmBtn         = this.el.find('.remove-item-button');
    this.quantity      = this.el.find('.product-info');
    this.cartItem      = cartDrawer.find('[data-menu-product-id=' + this.menuProductId + ']');

    this.addForm.on('submit', addAsync);
    this.rmBtn.on('click', this.reduceQtd.bind(this));
  }

  ProductCard.prototype.render = function(cartDrawer) {
    this.cartItem = cartDrawer.find('[data-menu-product-id=' + this.menuProductId + ']');
    cartItemQtd = parseInt(this.cartItem.find('.quantity').text() || 0);

    if (cartItemQtd <= 1) {
      this.rmBtn.addClass('hide');
    } else {
      this.rmBtn.removeClass('hide');
    }

    if (cartItemQtd > 0) {
      this.quantity.text(cartItemQtd);
    } else {
      this.quantity.text('');
    }
  };

  ProductCard.prototype.reduceQtd = function() {
    this.cartItem.find('form:has(.reduce-quantity)').submit();
  };

  init();

  function init() {
    cart = $('.cart');
    cartIconMenu = $('.cart-icon-menu');
    drawer = $('.drawer');
    productCards = $('.items-list .product').map(function(i, el) {
      productCard = new ProductCard($(el), cart);
      return productCard;
    });

    setupDrawer({ showOverlay: true });
    setupBindings(cart);
    render(cart);
  }

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
    checkoutButton = cart.find('.checkout-button');
    cart.find('.close').click(function closeCart(){close();});
    cart.find('form:has(.remove-item-button)').submit(removeAsync);
    cart.find('.update-delivery-time').change(updateDeliveryTimeAsync);
    cart.find('form:has(.update-quantity)').submit(updateQuantityAsync);
  }

  function render(cart) {
    var totalItemsCount = calculateCartItemsCount(extractQuantities(cart));
    $('.cart-icon .badge, .cart-items-quantity').text(totalItemsCount);
    if (totalItemsCount == 0) {
      cart.find('.remove-item-button').addClass('hide');
      cartIconMenu.addClass("hide");
      close();
    } else {
      cart.find('.remove-item-button').removeClass('hide');
      cartIconMenu.removeClass("hide");
    }

    var valid = cart
      .find(".date-items")
      .map(extractQuantities)
      .map(calculateCartItemsCount)
      .toArray()
      .every(greaterOrEqualTo(3));

    checkoutButton.toggleClass('disabled', !valid);
    if (valid) {
      checkoutButton.tooltip('destroy');
    } else {
      checkoutButton.tooltip();
    }

    productCards.each(_render);
    function _render(_, item) { item.render(cart); }

    function extractQuantities(element) {
      element = arguments[arguments.length - 1];
      return $(element).find('.cart-item .quantity');
    }

    function greaterOrEqualTo(x) {
      return function delayedGreaterOrEqualTo(y) {
        return y >= x;
      }
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
    return function delayedUpdateCart(cartHtml) {
      cart.html(cartHtml);
      setupBindings(cart);
      render(cart);
      new Alert({
        message: message,
        closeable: true,
        autoclose: 1000
      });
    };
  }

  function calculateCartItemsCount(cartItems) {
    cartItems = arguments[arguments.length - 1];
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
    .done(updateCart(successMessage, form))
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

  function updateDeliveryTimeAsync(ev) {
    asyncSubmit(
      ev,
      $(this.form),
      "PATCH",
      "Delivery time updated!",
      "There was a problem updating the delivery time."
    );
  }
});
