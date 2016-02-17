require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Orders' do
  header 'Authorization', :authorization
  let(:authorization) { "Bearer #{token}" }
  let(:token) { AuthToken.encode(user_id: user.id) }
  let(:user) { create(:user) }

  get '/orders.json' do
    let!(:old_order) { create(:order, user: user, created_at: 2.days.ago) }
    let!(:new_order) { create(:order, user: user) }
    let!(:another_user_order) { create(:order) }

    example_request "it's successful" do
      expect(response_status).to be 200
    end

    example "getting user's orders", document: :public do
      do_request
      expect(json).to eq(
        [
          {
            "id" => new_order.id,
            "status" => new_order.status,
            "amount_cents" => new_order.amount_cents,
            "amount_currency" => new_order.amount_currency,
            "created_at" => new_order.created_at.iso8601(3),
            "delivery_address" => new_order.delivery_address,
            "observations" => new_order.observations
          },
          {
            "id" => old_order.id,
            "status" => old_order.status,
            "amount_cents" => old_order.amount_cents,
            "amount_currency" => old_order.amount_currency,
            "created_at" => old_order.created_at.iso8601(3),
            "delivery_address" => old_order.delivery_address,
            "observations" => old_order.observations
          }
        ]
      )
    end
  end

  post '/orders.json' do
    parameter :stripeToken, "Stripe's single-use token (check https://stripe.com/docs/tutorials/forms for more information)"
    parameter :delivery_address, scope: :order
    parameter :observations, "Order observations (for example, \"I'm the guy using a black shirt\")", scope: :order
    let(:stripe_helper) { StripeMock.create_test_helper }
    let!(:cart) { create(:cart, user: user) }
    let!(:cart_items) { [cart.add(create(:menu_product), 1)] }
    let(:observations) { 'Take off the bacon!' }
    let(:stripeToken) { stripe_helper.generate_card_token }
    let(:delivery_address) { "18th Street Atlanta" }

    example "creating an order", document: :public do
      do_request
      expect(response_status).to be 200
    end

    example_request "creates an order associated with the cart items" do
      expect(Order.last.cart_items).to eq cart_items
    end

    context "record errors" do
      before do
        allow_any_instance_of(Cart).to receive(:destroy!).and_raise(ActiveRecord::RecordInvalid, cart)
      end

      example_request "it failed" do
        expect(response_status).to be 422
      end

      example "internal error when creating an order", document: :public do
        do_request
        expect(json).to eq(
          "error" => "Something went wrong. Contact us and we'll solve the problem."
        )
      end
    end

    context "when neither stripe token nor stripe source id are given" do
      let(:stripeToken) { nil }

      example_request "it failed" do
        expect(response_status).to be 422
      end

      example "error when didn't send the stripe token", document: :public do
        do_request
        expect(json).to eq(
          "error" => "A credit card must be selected"
        )
      end
    end

    context "stripe errors" do
      let(:error_message) { 'some external error' }

      before do
        allow(Stripe::Customer).to receive(:retrieve)
        .and_raise(Stripe::APIError, error_message)
      end

      example_request "it failed" do
        expect(response_status).to be 400
      end

      example "stripe error when creating an order", document: :public do
        do_request
        expect(json).to eq(
          "error" => error_message
        )
      end
    end
  end
end
