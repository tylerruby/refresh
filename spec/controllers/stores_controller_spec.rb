require 'rails_helper'

RSpec.describe StoresController, type: :controller do
  before do
    Geocoder::Lookup::Test.add_stub("4th Av., Augusta, GA", [
      {
        'latitude'     => 40.7143528,
        'longitude'    => -74.0059731,
        'address'      => '4th Av., Augusta, GA',
        'state'        => 'Georgia',
        'state_code'   => 'GA',
        'country'      => 'United States',
        'country_code' => 'US'
      }
    ])

    Geocoder::Lookup::Test.add_stub("3905 Mike Padgett Hwy, Augusta, GA", [
      {
        'latitude'     => 33.353523,
        'longitude'    => -81.982439,
        'address'      => '3905 Mike Padgett Hwy, Augusta, GA',
        'state'        => 'Georgia',
        'state_code'   => 'GA',
        'country'      => 'United States',
        'country_code' => 'US'
      }
    ])
  end

  describe "GET #search_by_city" do
    let(:augusta) { create(:city, name: 'Augusta') }
    let(:current_address) do
      create :address, city: augusta, address: '3905 Mike Padgett Hwy'
    end

    let!(:available_store) do
      create :store, address: create(:address,
        city: augusta, address: '3905 Mike Padgett Hwy')
    end
    let!(:available_product) { create(:product, store: available_store) }

    let!(:unavailable_store) do
      create :store,
        address: create(:address, city: augusta, address: '4th Av.')
    end
    let!(:unavailable_product) { create(:product, store: unavailable_store) }

    let(:atlanta) { create(:city, name: 'Atlanta') }
    let!(:store_in_another_city) do
      create :store, address: create(:address, city: atlanta)
    end
    let!(:product_from_store_in_another_city) do
      create :product, store: store_in_another_city
    end

    def do_action
      get :search_by_city, city: 'augusta'
    end

    before do
      allow_any_instance_of(Store).to receive(:available_for_delivery?).and_return(true)
      allow_any_instance_of(ApplicationController)
        .to receive(:current_address).and_return(current_address)
    end

    it "sets the city's name" do
      do_action
      expect(assigns[:city]).to eq 'Augusta'
    end

    it "result contains available stores only" do
      do_action
      expect(assigns[:stores]).to match_array [available_store]
    end

    pending "order by distance"
  end

  describe "GET #show" do
    let(:augusta) { create(:city, name: 'Augusta') }
    let!(:store) { create(:store, address: create(:address, city: augusta)) }
    let!(:available_product) { create(:product, store: store, available: true) }
    let!(:unavailable_product) { create(:product, store: store, available: false) }
    let!(:product_from_store_in_another_city) { create(:product) }

    def do_action
      get :show, id: store.friendly_id
    end

    it "assigns the store" do
      do_action
      expect(assigns[:store]).to eq store
    end

    it "assigns the available_products" do
      do_action
      expect(assigns[:available_products]).to eq [available_product]
    end
  end
end
