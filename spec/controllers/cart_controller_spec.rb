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
      old_cart_item = cart.add(create(:product), 1)
      new_cart_item = cart.add(create(:product), 1)
      old_cart_item.touch
      session[:cart_id] = cart.id
      do_action
      expect(assigns[:cart]).to eq cart
      expect(assigns[:cart_items]).to eq [old_cart_item, new_cart_item]
    end
  end

  describe "PATCH #add" do
    let(:store) { create(:store) }
    let(:product) { create(:product, store: store) }

    before do
      session[:address_id] = store.address.id
    end

    let(:quantity) { 3 }

    def do_action
      patch :add, quantity: quantity, product_id: product.id
    end

    context "product from a store available for delivery" do
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

      it "creates a product instance with the correct attributes" do
        expect { do_action }.to change { Product.count }.by(1)
        product = Product.last
        expect(product.store).to eq store
      end

      it "doesn't allow a product instance that references an inexistent product variant id" do
        skip
        expect do
          patch :add, quantity: 0, product_id: product.id
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "adds the product instance to the cart with the product's price and with the correct quantity" do
        do_action
        cart = Cart.last
        cart_item = CartItem.last
        expect(cart.subtotal).to eq product.price * quantity
        expect(cart.shopping_cart_items).to eq [cart_item]
        expect(cart_item.quantity).to eq quantity
        expect(cart_item.price).to eq product.price
        expect(cart_item.item).to eq Product.last
      end

      it "adds a product instance to the existing cart" do
        cart = Cart.create!
        session[:cart_id] = cart.id
        do_action
        expect(cart.reload.shopping_cart_items.last.item).to eq Product.last
      end

      it "adds equal product instance to the existing cart item" do
        do_action
        do_action

        cart = Cart.last
        cart_item = CartItem.last
        expect(cart.shopping_cart_items).to eq [cart_item]
        expect(cart_item.quantity).to eq quantity * 2
        expect(cart.subtotal).to eq product.price * quantity * 2
      end
    end

    describe "product from a store which isn't available for delivery" do
      before do
        skip 'Authorization'
        store.update!(address: create(:far_far_away))
      end

      it "raises an exception when trying to add" do
        expect { do_action }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "DELETE #remove" do
    let(:previous_url) { '/previous_url' }
    let(:cart) { Cart.create! }
    let(:product) { create(:product) }

    before do
      request.env["HTTP_REFERER"] = previous_url
      cart.add(product, product.price, 3)
      session[:cart_id] = cart.id
    end

    def do_action
      delete :remove, product_id: product.id
    end

    it "removes the product instance from the cart" do
      do_action
      expect(cart.reload).to be_empty
    end

    it "redirects the user back to the the previous page" do
      do_action
      expect(response).to redirect_to previous_url
    end

    it "sets a success message" do
      do_action
      expect(flash[:success]).to eq 'Item removed from the cart.'
    end
  end

  describe "PATCH #update" do
    let(:previous_url) { '/previous_url' }
    let(:cart) { Cart.create! }
    let(:quantity) { 3 }
    let(:product) { create(:product) }
    let(:cart_item) { cart.add product, product.price, 2 }

    def do_action
      cart_item
      patch :update, quantity: quantity, product_id: product.id
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

    it "redirects the user back to the the previous page" do
      do_action
      expect(response).to redirect_to previous_url
    end

    it "sets a success message" do
      do_action
      expect(flash[:success]).to eq "Item's quantity updated to #{quantity}."
    end
  end
end
