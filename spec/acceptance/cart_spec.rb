require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Cart' do
  header 'Authorization', :authorization
  let(:authorization) { "Bearer #{token}" }
  let(:token) { AuthToken.encode(user_id: user.id) }
  let(:user) { create(:user) }

  get '/cart.json' do
    example_request "it's successful" do
      expect(response_status).to be 200
    end

    example_request "returns a new cart" do
      expect(json).to eq(
        "cart" => {
          "subtotal_cents" => 0,
          "subtotal_currency" => "USD",
          "total_cents" => 200,
          "total_currency" => "USD",
          "cart_items" => []
        }
      )
    end

    example_request "associates the new cart with the current user" do
      expect(user.reload.cart).to eq Cart.last
    end

    context "existing cart" do
      let!(:cart) { create(:cart, user: user) }
      let!(:product) { create(:product, price: '2.50') }
      let!(:cart_item) { cart.add(product, product.price, 2) }

      example_request "it's successful" do
        expect(response_status).to be 200
      end

      example "getting the cart with its items", document: :public do
        do_request
        expect(json).to eq(
          "cart" => {
            "subtotal_cents" => 500,
            "subtotal_currency" => "USD",
            "total_cents" => 700,
            "total_currency" => "USD",
            "cart_items" => [
              {
                "quantity" => 2,
                "subtotal_cents" => 500,
                "subtotal_currency" => "USD",
                "product" => {
                  "id" => product.id,
                  "name" => product.name,
                  "description" => product.description,
                  "price_cents" => 250,
                  "price_currency" => "USD",
                  "image" => product.image.url(:thumb),
                  "store" => {
                    "id" => product.store.id,
                    "name" => product.store.name
                  }
                }
              }
            ]
          }
        )
      end
    end
  end

  patch '/cart/add.json' do
    parameter :product_id, "The product's id"
    parameter :quantity, "How many items to add for that product"
    let(:quantity) { 1 }
    let(:product) { create(:product) }
    let(:product_id) { product.id }

    example "adding a product to the cart", document: :public do
      do_request
      expect(response_status).to be 200
    end
  end

  delete '/cart/remove.json' do
    parameter :product_id, "The product's id"
    let(:product) { create(:product) }
    let(:product_id) { product.id }
    let!(:cart) { create(:cart, user: user) }
    let!(:cart_item) { cart.add(product, product.price, 1) }

    example "removing a product from the cart", document: :public do
      do_request
      expect(response_status).to be 200
    end
  end

  patch '/cart/update.json' do
    parameter :product_id, "The product's id"
    parameter :quantity, "How many items to set for that product"
    let(:quantity) { 2 }
    let(:product) { create(:product) }
    let(:product_id) { product.id }
    let!(:cart) { create(:cart, user: user) }
    let!(:cart_item) { cart.add(product, product.price, 1) }

    example "updating a cart item's quantity", document: :public do
      do_request
      expect(response_status).to be 200
    end
  end
end
