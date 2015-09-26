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
    let!(:first_store) { create(:store, city: 'Augusta') }
    let!(:first_cloth) { create(:cloth, chain: first_store.chain) }

    let!(:second_store) { create(:store, chain: first_store.chain, city: 'Augusta') }
    let!(:second_cloth) { create(:cloth, chain: second_store.chain) }

    let!(:store_in_another_city) { create(:store, city: 'Atlanta') }
    let!(:cloth_from_store_in_another_city) { create(:cloth, chain: store_in_another_city.chain) }

    def do_action
      get :search_by_city, city: 'augusta'
    end

    before { do_action }

    it { expect(assigns[:city]).to eq 'Augusta' }
    it { expect(assigns[:stores]).to eq [first_store, second_store] }
    it { expect(assigns[:clothes]).to eq [first_cloth, second_cloth] }
    it { expect(assigns[:clothes].first.store).to eq first_store }

    pending "order by distance"
  end
end
