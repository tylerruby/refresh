$(function setupCart() {
  var ProductCard;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  ProductCard = (function() {
    function ProductCard(el, cartDrawer) {
      this.el            = el;
      this.menuProductId = this.el.data('menuProductId');
      this.addForm       = this.el.find('form.new_cart_item');
      this.addBtn        = this.el.find('.add-item-button');
      this.rmBtn         = this.el.find('.remove-item-button');
      this.quantity      = this.el.find('.product-info');
      this.cartItem      = cartDrawer.find('[data-menu-product-id=' + this.menuProductId + ']');
      this.reduceQtd     = __bind(this.reduceQtd, this);

      this.addForm.on('submit', addAsync);
      this.rmBtn.on('click', this.reduceQtd);
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

    return ProductCard;
  })();

  var cart = $('.cart');
  var cartIconMenu = $('.cart-icon-menu');
  var drawer = $('.drawer');

  var productCards = $('.items-list .product').map(function(i, el) {
    productCard = new ProductCard($(el), cart);
    productCard.render(cart);
    return productCard;
  });

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
    cart.find('.close').click(function closeCart(){close();});
    cart.find('form:has(.remove-item-button)').submit(removeAsync);
    cart.find('.update-delivery-time').change(updateDeliveryTimeAsync);
    cart.find('form:has(.update-quantity)').submit(updateQuantityAsync);

    var cartItemsCount = calculateCartItemsCount(cart.find('.cart-item .quantity'));
    $('.cart-icon .badge, .cart-items-quantity').text(cartItemsCount);
    if (cartItemsCount == 0) {
      cart.find('.remove-item-button').addClass('hide');
      cartIconMenu.addClass("hide");
      close();
    } else {
      cart.find('.remove-item-button').removeClass('hide');
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
    return function delayedUpdateCart(cartHtml) {
      cart.html(cartHtml);
      setupBindings(cart);
      productCards.each(function(i, productCard) {productCard.render(cart);});
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
