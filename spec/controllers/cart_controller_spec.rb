require 'rails_helper'

RSpec.describe CartController, type: :controller do

  describe "GET #index" do
    def do_action
      get :index
    end

    it "creates a cart" do
      do_action
      cart = Cart.last
      expect(session[:cart_id]).to eq cart.id
      expect(assigns[:cart]).to eq cart
      expect(assigns[:cart_items]).to eq []
    end

    it "sets an existing cart" do
      cart = Cart.create!
      old_cart_item = cart.add(create(:menu_product), 1)
      new_cart_item = cart.add(create(:menu_product), 1)
      old_cart_item.touch
      session[:cart_id] = cart.id
      do_action
      expect(assigns[:cart]).to eq cart
      expect(assigns[:cart_items]).to eq [old_cart_item, new_cart_item]
    end
  end

  describe "PATCH #add" do
    let(:menu_product) { create(:menu_product, menu: menu, product: product) }
    let(:product) { create(:product) }
    let(:menu) { create(:menu, date: Date.current, region: region) }
    let(:region) { create(:region, address: create_address) }

    let(:quantity) { 3 }

    def create_address
      create(:address)
    end

    def do_action
      session[:address_id] = create_address.id
      patch :add, quantity: quantity, menu_product_id: menu_product.id
    end

    it "creates a cart" do
      do_action
      expect(session[:cart_id]).to eq Cart.last.id
    end

    it "recreates a cart" do
      do_action
      Cart.last.destroy!
      do_action
      expect(session[:cart_id]).to eq Cart.last.id
    end

    it "adds the MenuProduct to the cart with the product's price and with the correct quantity" do
      do_action
      cart = Cart.last
      cart_item = CartItem.last
      expect(cart.subtotal).to eq product.price * quantity
      expect(cart.shopping_cart_items).to eq [cart_item]
      expect(cart_item.quantity).to eq quantity
      expect(cart_item.price).to eq product.price
      expect(cart_item.item).to eq MenuProduct.last
    end

    it "adds a MenuProduct to the existing cart" do
      cart = Cart.create!
      session[:cart_id] = cart.id
      do_action
      expect(cart.reload.shopping_cart_items.last.item).to eq menu_product
    end

    it "adds equal MenuProducts to the existing cart item" do
      do_action
      do_action

      cart = Cart.last
      cart_item = CartItem.last
      expect(cart.shopping_cart_items).to eq [cart_item]
      expect(cart_item.quantity).to eq quantity * 2
      expect(cart.subtotal).to eq product.price * quantity * 2
    end
  end

  describe "DELETE #remove" do
    let(:previous_url) { '/previous_url' }
    let(:cart) { Cart.create! }
    let(:menu_product) { create(:menu_product) }
    let(:product) { menu_product.product }

    before do
      request.env["HTTP_REFERER"] = previous_url
      cart.add(menu_product, product.price, 3)
      session[:cart_id] = cart.id
    end

    def do_action
      delete :remove, menu_product_id: menu_product.id
    end

    it "removes the MenuProduct from the cart" do
      do_action
      expect(cart.reload).to be_empty
    end
  end

  describe "PATCH #update" do
    let(:previous_url) { '/previous_url' }
    let(:cart) { Cart.create! }
    let(:quantity) { 3 }
    let(:menu_product) { create(:menu_product) }
    let(:product) { menu_product.product }
    let(:cart_item) { cart.add menu_product, product.price, 2 }

    def do_action
      cart_item
      patch :update, quantity: quantity, menu_product_id: menu_product.id
    end

    before do
      request.env["HTTP_REFERER"] = previous_url
      session[:cart_id] = cart.id
    end

    it "updates the cart item's quantity" do
      do_action
      expect(cart_item.reload.quantity).to eq quantity
      expect(cart.reload.subtotal).to eq product.price * quantity
    end
  end
end
