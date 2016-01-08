require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Stores' do
  header 'Authorization', :authorization
  let(:authorization) { "Bearer #{token}" }
  let(:token) { AuthToken.encode(user_id: user.id) }
  let(:user) { create(:user) }
  let(:atlanta) { create(:city, name: 'Atlanta') }

  before do
    stub_address("3905 Mike Padgett Hwy, Atlanta, GA", 33.353523, -81.982439)
  end

  post '/:city.json' do
    parameter :address, "The user's current address"
    let(:address) { '3905 Mike Padgett Hwy' }
    let(:city) { 'atlanta' }
    let!(:available_store) do
      create :store,
        human_opens_at: '21:00', human_closes_at: '03:00',
        address: available_address
    end
    def available_address 
      create :address, city: atlanta, address: '3905 Mike Padgett Hwy'
    end

    before do
      Timecop.travel Time.zone.parse('01-01-2016 01:00')
      allow_any_instance_of(Store).to receive(:available_for_delivery?).and_return(true)
    end

    example_request "it's successful" do
      expect(response_status).to be 200
    end

    example "getting the current opened store", document: :public do
      do_request
      expect(json).to eq(
        "store" => {
          "id" => available_store.id
        }
      )
    end

    example_request "sets the user's current address" do
      expect(user.reload.current_address.city).to eq atlanta
      expect(user.reload.current_address.address).to eq address
    end
  end

  get '/:city/:store_id.json' do
    let(:city) { 'atlanta' }
    let(:store_id) { store.id }
    let!(:store) { create(:store, address: create(:address, city: atlanta)) }

    let!(:available_product) { create(:product, store: store, available: true) }
    let!(:unavailable_product) { create(:product, store: store, available: false) }
    let!(:product_from_store_in_another_city) { create(:product) }

    example_request "it's successful" do
      expect(response_status).to be 200
    end

    example "getting the store with its products", document: :public do
      do_request
      expect(json).to eq(
        "store" => {
          "id" => store.id,
          "name" => store.name,
          "image" => store.image.url(:thumb),
          "opens_at" => store.opens_at,
          "closes_at" => store.closes_at,
          "products" => [
            {
              "id" => available_product.id,
              "name" => available_product.name,
              "description" => available_product.description,
              "price_cents" => available_product.price_cents,
              "price_currency" => available_product.price_currency,
              "image" => available_product.image.url(:thumb)
            }
          ]
        }
      )
    end
  end
end
