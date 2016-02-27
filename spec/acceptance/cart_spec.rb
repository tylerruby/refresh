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
      let(:product) { create(:product, price: '2.50') }
      let(:date) { '2016-01-01' }
      let(:menu) { create(:menu, date: date) }
      let!(:menu_product) { create(:menu_product, menu: menu, product: product) }
      let!(:cart_item) { cart.add(menu_product, product.price, 2) }

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
                "menu_product" => {
                  "menu" => {
                    "id" => menu.id,
                    "date" => date
                  },
                  "product" => {
                    "id" => product.id,
                    "name" => product.name,
                    "description" => product.description,
                    "price_cents" => 250,
                    "price_currency" => "USD",
                    "image" => product.image.url(:thumb)
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
    parameter :menu_product_id, "The MenuProduct's id"
    parameter :quantity, "How many items to add for that product"
    let(:quantity) { 1 }
    let(:region) { create(:region, address: user.current_address.dup) }
    let(:menu) { create(:menu, date: Date.current, region: region) }
    let(:menu_product) { create(:menu_product, menu: menu) }
    let(:menu_product_id) { menu_product.id }

    pending "test and document failed authorization cases"

    example "adding a menu product to the cart", document: :public do
      do_request
      expect(response_status).to be 200
    end

    example_request "created a CartItem associated with the MenuProduct" do
      expect(CartItem.last.item).to eq menu_product
    end
  end

  delete '/cart/remove.json' do
    parameter :menu_product_id, "The MenuProduct's id"
    let(:menu_product) { create(:menu_product) }
    let(:menu_product_id) { menu_product.id }
    let!(:cart) { create(:cart, user: user) }
    let!(:cart_item) { cart.add(menu_product, menu_product.product.price, 1) }

    example "removing a product from the cart", document: :public do
      do_request
      expect(response_status).to be 200
    end

    example_request "removed the CartItem" do
      expect(cart.reload.shopping_cart_items).to be_empty
    end
  end

  patch '/cart/update.json' do
    parameter :menu_product_id, "The MenuProduct's id"
    parameter :quantity, "How many items to set for that product"
    let(:quantity) { 2 }
    let(:menu_product) { create(:menu_product) }
    let(:menu_product_id) { menu_product.id }
    let!(:cart) { create(:cart, user: user) }
    let!(:cart_item) { cart.add(menu_product, menu_product.product.price, 1) }

    example "updating a cart item's quantity", document: :public do
      do_request
      expect(response_status).to be 200
    end

    example_request "updated the quantity" do
      expect(cart_item.reload.quantity).to eq quantity
    end
  end
end
