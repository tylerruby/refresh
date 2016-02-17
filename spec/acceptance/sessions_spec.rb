require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Sessions' do
  post '/users/sign_in.json' do
    parameter :email, scope: :user
    parameter :password, scope: :user
    let(:password) { '12345678' }
    let(:email) { user.email }

    let!(:user) { create(:user, password: password) }
    let(:token) do
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IiI.-IZCxF2OTSg7vVCuU5MJlJ65DLGHv49LI-9YsyllVIo'
    end
    let!(:card) { add_credit_card(user) }

    before do
      allow(AuthToken)
        .to receive(:encode)
        .with(user_id: user.id)
        .and_return(token)
    end

    example_request "it's successful" do
      expect(response_status).to be 200
    end

    example "sign in with email and password", document: :public do
      do_request
      expect(json).to eq(
        "id" => user.id,
        "mobile_number" => nil,
        "credit_cards" => [
          "id" => card.id,
          "type" => card.type,
          "last4" => card.last4
        ],
        "token" => token
      )
    end

    context "wrong email" do
      let(:email) { 'some.other.email@example.com' }

      example "failing to authenticate" do
        do_request
        expect(json).to eq("error" => "Invalid email or password.")
      end
    end
  end

  post '/auth/:provider.json', :vcr do
    before { skip "Shouldn't use S3 on tests" }
    parameter :code
    parameter :redirectUri
    let(:code) do
      "AQCNbreRDeFL5GAQILSs6MUhA7FZIzeEpDyUWVBSpFK9UJHYd-pZMIjwD9eOiH45ggEQGVtMMbA6r8AipsxqX4LSX5YFemmVLm2mgD5EmOqQ0aPaDOIxza_WYgOV7MFB-u6dMcJDjXwlUgRsqLTmigpIKVP1Jkod1ImvO_l53vJsLoUl5LT9UegnUuG8SsG93ZImizDrm5GD3rwrNrpoOFdKflljKtUe1sKyt8aJ2oEt7ByE80Z78zIcNJ6bhTfEYY9_bQLQBW0TfXi4tjysuP3McUUnwW089S26lJly98UK3stZeWpbb7i8kySfGE33z4W9AA2XSfeIcZ25BswfaU1_ZxHtj_2eGdSRUWAXfj46LQ"
    end
    let(:redirectUri) { "http://localhost:3000/" }
    let(:user) do
      create :user, provider: "facebook", uid: "1036740603037267"
    end
    let(:token) do
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IiI.-IZCxF2OTSg7vVCuU5MJlJ65DLGHv49LI-9YsyllVIo'
    end
    let(:provider) { 'facebook' }
    let!(:card) { add_credit_card(user) }

    before do
      allow(AuthToken)
        .to receive(:encode)
        .with(user_id: user.id)
        .and_return(token)
    end

    example "authenticating user from Facebook", document: :public do
      do_request
      expect(json).to eq(
        "id" => user.id,
        "mobile_number" => nil,
        "credit_cards" => [
          "id" => card.id,
          "type" => card.type,
          "last4" => card.last4
        ],
        "token" => token
      )
    end
  end

  get '/user/new_token.json' do
    header 'Authorization', :authorization
    let(:authorization) { "Bearer #{token}" }
    let(:token) { AuthToken.encode(user_id: user.id) }
    let(:user) { create(:user) }

    let(:new_token) do
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IiI.-IZCxF2OTSg7vVCuU5MJlJ65DLGHv49LI-9YsyllVIo'
    end

    before do
      token
      allow(AuthToken)
        .to receive(:encode)
        .with(user_id: user.id)
        .and_return(new_token)
    end

    example "get a new token", document: :public do
      do_request
      expect(json).to eq(
        "id" => user.id,
        "mobile_number" => nil,
        "credit_cards" => [],
        "token" => new_token
      )
    end

    context "trying to get new token after expired" do
      before do
        token
        Timecop.travel 1.month.from_now
      end

      example "fails to get a new token after the previous was expired" do
        do_request
        expect(response_status).to be 401
      end
    end
  end
end
