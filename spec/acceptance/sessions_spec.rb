require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Sessions' do
  post '/users/sign_in.json' do
    parameter :email, scope: :user
    parameter :password, scope: :user
    let!(:user) { create(:user, password: password) }
    let(:password) { '12345678' }
    let(:email) { user.email }
    let(:token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IiI.-IZCxF2OTSg7vVCuU5MJlJ65DLGHv49LI-9YsyllVIo' }

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
    let(:user) do
      create :user, provider: "facebook", uid: "1036740603037267"
    end
    parameter :code
    parameter :redirectUri
    let(:code) do
      "AQAbPYPr-aVYV5DhQVJBlUdAEqjwllnbt3TKDmIGR9I9LY6el22kzSiQS5MXyWT-EXiO3Wfv7HWnyhn18jwUuRxZEP7ILv0dUmvczR4GjYYk7YdeZaOo4T5WcWqOgYE49QMRrTSH22lc3RfYnehHyyplQ-8sZNotw2Mh0wXdVtUcmIBedtlS8dKYSJ_8OmORqWRb-5Mo7wkMMaYV8WgZQ-ngR0IQc_f79cDyrKKkwNz19guCNFbVJu3J-qU5kSex1qp0_3xwwtmH8cU3REOjaXVzfdAbRK0zPdAZq5T6FhjiWFrH1SkNAqJrN7bUQn7IrCXaY-WOOGwZ67kB4NmHSUig36nBLbvohGJelVCvGTlnUQ#_=_"
    end
    let(:redirectUri) { "http://localhost:3000/" }
    let(:token) do
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IiI.-IZCxF2OTSg7vVCuU5MJlJ65DLGHv49LI-9YsyllVIo'
    end
    let(:provider) { 'facebook' }

    before do
      allow(AuthToken)
        .to receive(:encode)
        .with(user_id: user.id)
        .and_return(token)
    end

    example "authenticating user from Facebook" do
      do_request
      expect(json).to eq(
        "id" => user.id,
        "token" => token
      )
    end
  end
end
