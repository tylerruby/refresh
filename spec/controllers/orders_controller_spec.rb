require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:user) { create(:user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #index" do
    let!(:old_order) { create(:order, user: user, created_at: 2.days.ago) }
    let!(:new_order) { create(:order, user: user) }
    let!(:another_user_order) { create(:order) }

    def do_action
      get :index
    end

    context "authenticated" do
      before do
        sign_in user
      end

      it "returns all the orders for the user" do
        do_action
        expect(assigns[:orders]).to eq [new_order, old_order]
      end
    end

    context "unauthenticated" do
      it "should redirect the user to the sign in page" do
        do_action
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #new" do
    def do_action
      get :new
    end

    describe "authenticated" do
      let(:cart) { Cart.create! }

      before do
        session[:cart_id] = cart.id
        sign_in user
      end

      it "sets the cart for the user" do
        do_action
        expect(assigns[:cart]).to eq cart
      end
    end
  end

  describe "POST #create" do
    let(:token) { 'some token' }
    let(:customer_double) { double('Stripe::Customer', id: 'some id') }

    def do_action
      post :create, stripeToken: token
    end

    def order
      Order.last
    end

    context "authenticated" do
      let!(:cart) { Cart.create! }
      let!(:cart_items) { 2.times.map { cart.add(create(:cloth_instance), 1) } }

      before do
        session[:cart_id] = cart.id
        sign_in user

        allow(Stripe::Customer).to receive(:create).with(
          card: token,
          description: 'Paying user',
          email: user.email
        ).and_return(customer_double)

        allow(Stripe::Charge).to receive(:create).with(
          :amount   => cart.total.cents,
          :currency => "usd",
          :customer => customer_double.id
        )
      end

      it "creates a new order from the cart" do
        expect {
          do_action
        }.to change(Order, :count).by(1)
      end

      describe "post-conditions" do
        before do
          do_action
        end

        it { expect(order.cart_items).to eq cart_items }
        it { expect(order.user).to eq user }
        it { expect(order.amount).to eq cart.total }
        it { expect(order.status).to eq 'waiting_confirmation' }
        it { expect(Cart.exists? cart.id).to be false }
        it { expect(Stripe::Customer).to have_received(:create) }
        it { expect(Stripe::Charge).to have_received(:create) }

        it "redirects to root path" do
          expect(response).to redirect_to root_path
        end

        it "sets a success message" do
          expect(flash[:success]).to eq "Checkout was successful! Waiting confirmation..."
        end
      end

      context "handling failure" do
        context "record errors" do
          before do
            allow_any_instance_of(Cart).to receive(:destroy!).and_raise(ActiveRecord::RecordInvalid, cart)
          end

          it "creates a new order nonetheless" do
            expect {
              do_action
            }.to change(Order, :count).by(1)
          end

          describe "post-conditions" do
            before do
              do_action
            end

            it "undoes the cart destruction" do
              expect(Cart.exists? cart.id).to be true
              expect(cart.reload.shopping_cart_items).to eq cart_items
            end

            it "sets the order to an internal failure status" do
              expect(order.status).to eq 'internal_failure'
            end

            it "shows an error message" do
              expect(flash[:danger]).to eq "Something went wrong. Contact us and we'll solve the problem."
              expect(flash[:success]).to be_nil
            end

            it "doesn't call stripe" do
              expect(Stripe::Customer).not_to have_received(:create)
              expect(Stripe::Charge).not_to have_received(:create)
            end
          end
        end

        context "stripe errors" do
          let(:error_message) { 'some external error' }

          before do
            allow(Stripe::Customer).to receive(:create)
              .and_raise(Stripe::APIError, error_message)
          end

          it "creates a new order nonetheless" do
            expect {
              do_action
            }.to change(Order, :count).by(1)
          end

          describe "post-conditions" do
            before do
              do_action
            end

            it "undoes the cart destruction" do
              expect(Cart.exists? cart.id).to be true
              expect(cart.reload.shopping_cart_items).to eq cart_items
            end

            it "sets the order to an external failure status" do
              expect(order.status).to eq 'external_failure'
            end

            it "shows the error message" do
              expect(flash[:danger]).to eq error_message
              expect(flash[:success]).to be_nil
            end
          end
        end
      end
    end

    context "unauthenticated" do
      it "should redirect the user to the sign in page" do
        do_action
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
