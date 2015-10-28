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
  end

  describe "GET #search_by_city" do
    let(:augusta) { create(:city, name: 'Augusta') }
    let!(:first_store) do
      create :store, address: create(:address, city: augusta)
    end
    let!(:first_cloth) { create(:cloth, chain: first_store.chain) }

    let!(:second_store) do
      create :store,
        chain: first_store.chain,
        address: create(:address, city: augusta)
    end
    let!(:second_cloth) { create(:cloth, chain: second_store.chain) }

    let(:atlanta) { create(:city, name: 'Atlanta') }
    let!(:store_in_another_city) do
      create :store, address: create(:address, city: atlanta)
    end
    let!(:cloth_from_store_in_another_city) do
      create :cloth, chain: store_in_another_city.chain
    end

    def do_action
      get :search_by_city, city: 'augusta'
    end

    before do
      allow_any_instance_of(Store).to receive(:available_for_delivery?).and_return(true)
    end

    it "sets the city's name" do
      do_action
      expect(assigns[:city]).to eq 'Augusta'
    end

    it "sets the stores" do
      do_action
      expect(assigns[:stores]).to match_array [first_store, second_store]
    end

    pending "order by distance"
  end

  describe "GET #show" do
    let(:augusta) { create(:city, name: 'Augusta') }
    let!(:store) { create(:store, address: create(:address, city: augusta)) }
    let!(:first_cloth) { create(:cloth, chain: store.chain) }
    let!(:second_cloth) { create(:cloth, chain: store.chain) }
    let!(:cloth_from_store_in_another_city) { create(:cloth) }

    def do_action
      get :show, id: store.friendly_id
    end

    it "assigns the store" do
      do_action
      expect(assigns[:store]).to eq store
    end
  end
end
