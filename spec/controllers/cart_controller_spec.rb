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
      old_cart_item = cart.add(create(:cloth_instance), 1)
      new_cart_item = cart.add(create(:cloth_instance), 1)
      old_cart_item.touch
      session[:cart_id] = cart.id
      do_action
      expect(assigns[:cart]).to eq cart
      expect(assigns[:cart_items]).to eq [old_cart_item, new_cart_item]
    end
  end

  describe "GET #add" do
    let(:previous_url) { '/previous_url' }
    let(:store) { create(:store) }

    before do
      request.env["HTTP_REFERER"] = previous_url
    end

    let(:cloth_variant) { create(:cloth_variant) }
    let(:quantity) { 3 }
    let(:cloth_instance_attributes) do
      {
        size: "doesn't even matter",
        cloth_variant_id: cloth_variant.id,
        store_id: store.id
      }
    end

    def do_action
      patch :add, quantity: quantity, cloth_instance: cloth_instance_attributes
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

    it "creates a cloth instance with the correct attributes" do
      expect { do_action }.to change { ClothInstance.count }.by(1)
      cloth_instance = ClothInstance.last
      expect(cloth_instance.color).to eq cloth_variant.color
      expect(cloth_instance.size).to eq cloth_variant.size
      expect(cloth_instance.cloth_variant).to eq cloth_variant
      expect(cloth_instance.store).to eq store
    end

    it "doesn't allow a cloth instance that references an inexistent cloth variant id" do
      expect do
        patch :add, quantity: 0, cloth_instance: cloth_instance_attributes.merge(cloth_variant_id: -1)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "adds the cloth instance to the cart with the cloth's price and with the correct quantity" do
      do_action
      cart = Cart.last
      cart_item = CartItem.last
      expect(cart.subtotal).to eq cloth_variant.price * quantity
      expect(cart.shopping_cart_items).to eq [cart_item]
      expect(cart_item.quantity).to eq quantity
      expect(cart_item.price).to eq cloth_variant.price
      expect(cart_item.item).to eq ClothInstance.last
    end

    it "redirects the user back to the the previous page" do
      do_action
      expect(response).to redirect_to previous_url
    end

    it "sets a success message" do
      do_action
      expect(flash[:success]).to eq 'Item added to the cart!'
    end

    it "adds a cloth instance to the existing cart" do
      cart = Cart.create!
      session[:cart_id] = cart.id
      do_action
      expect(cart.reload.shopping_cart_items.last.item).to eq ClothInstance.last
    end

    it "adds equal cloth instance to the existing cart item" do
      do_action
      do_action

      cart = Cart.last
      cart_item = CartItem.last
      expect(cart.shopping_cart_items).to eq [cart_item]
      expect(cart_item.quantity).to eq quantity * 2
      expect(cart.subtotal).to eq cloth_variant.price * quantity * 2
    end
  end

  describe "GET #remove" do
    let(:previous_url) { '/previous_url' }
    let(:cart) { Cart.create! }
    let(:cloth_instance) { create(:cloth_instance) }

    before do
      request.env["HTTP_REFERER"] = previous_url
      cart.add(cloth_instance, cloth_instance.price, 3)
      session[:cart_id] = cart.id
    end

    def do_action
      delete :remove, cloth_instance_id: cloth_instance.id
    end

    it "removes the cloth instance from the cart" do
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

  describe "GET #update" do
    let(:previous_url) { '/previous_url' }
    let(:cart) { Cart.create! }
    let(:quantity) { 3 }
    let(:cloth_instance) { create(:cloth_instance) }
    let(:cart_item) { cart.add cloth_instance, cloth_instance.price, 2 }

    def do_action
      cart_item
      patch :update, quantity: quantity, cloth_instance_id: cloth_instance.id
    end

    before do
      request.env["HTTP_REFERER"] = previous_url
      session[:cart_id] = cart.id
    end

    it "updates the cart item's quantity" do
      do_action
      expect(cart_item.reload.quantity).to eq quantity
      expect(cart.reload.subtotal).to eq cloth_instance.price * quantity
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
