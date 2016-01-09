require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Users' do
  header 'Authorization', :authorization
  let(:authorization) { "Bearer #{token}" }
  let(:token) { AuthToken.encode(user_id: user.id) }
  let(:user) { create(:user) }

  post '/user/add_credit_card.json' do
    parameter :number, scope: :credit_card
    parameter :exp_year, scope: :credit_card
    parameter :exp_month, scope: :credit_card
    parameter :cvc, scope: :credit_card
    let(:number) { '4242 4242 4242 4242' }
    let(:exp_year) { '2025' }
    let(:exp_month) { '1' }
    let(:cvc) { '123' }

    example_request "adds the card to the user's cards on Stripe" do
      card = user.customer.sources.data[0]
      expect(
        number: card.number,
        exp_year: card.exp_year,
        exp_month: card.exp_month,
        cvc: card.cvc
      ).to eq(
        number: number,
        exp_year: exp_year.to_i,
        exp_month: exp_month.to_i,
        cvc: cvc
      )
    end

    example "adding a credit card for the user", document: :public do
      do_request
      expect(json["message"]).to eq 'Card added!'
    end
  end

  get '/user/remove_credit_card.json' do
    parameter :credit_card_id, "Stripe's credit card id"
    let(:credit_card_id) { user.credit_cards.first.id }

    def reset_stripe_customer
      user.instance_variable_set :@customer, nil
    end

    before do
      user.add_credit_card StripeMock.create_test_helper.generate_card_token
      reset_stripe_customer
    end

    example_request "removes the credit card from the list" do
      reset_stripe_customer
      expect(user.customer.sources.data.length).to be 0
    end

    example "removing user's credit card", document: :public do
      do_request
      expect(response_status).to eq 200
    end
  end
end
