require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Registrations' do
  post '/users.json' do
    parameter :email, scope: :user
    parameter :password, scope: :user
    let(:email) { 'some.email@example.com' }
    let(:password) { '12345678' }

    let(:token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IiI.-IZCxF2OTSg7vVCuU5MJlJ65DLGHv49LI-9YsyllVIo' }

    before do
      allow(AuthToken)
        .to receive(:encode)
        .with(hash_including(:user_id))
        .and_return(token)
    end

    example "creating an user", document: :public do
      do_request
      expect(json).to eq(
        "id" => User.last.id,
        "credit_cards" => [],
        "token" => token
      )
    end

    context "invalid password" do
      let(:password) { '' }

      example "failing to create an user", document: :public do
        do_request
        expect(json).to eq("password" => ["can't be blank"])
      end
    end
  end
end
