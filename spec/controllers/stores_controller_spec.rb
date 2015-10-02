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

    before do
      allow_any_instance_of(Store).to receive(:available_for_delivery?).and_return(true)
    end

    it "sets the city's name" do
      do_action
      expect(assigns[:city]).to eq 'Augusta'
    end

    it "sets the stores" do
      do_action
      expect(assigns[:stores]).to eq [first_store, second_store]
    end

    it "orders clothes by views" do
      Impression.create!(impressionable: second_cloth)
      do_action
      expect(assigns[:clothes]).to eq [second_cloth, first_cloth]
    end

    it "orders clothes by views in the last week" do
      2.times { Impression.create!(impressionable: first_cloth, created_at: 2.weeks.ago) }
      Impression.create!(impressionable: second_cloth)
      do_action
      expect(assigns[:clothes]).to eq [second_cloth, first_cloth]
    end

    it "sets respective store for each cloth" do
      do_action
      expect(assigns[:clothes].first.store).to eq first_store
    end

    it "shows only clothes from stores available for delivery" do
      allow_any_instance_of(Store).to receive(:available_for_delivery?).and_return(false)
      do_action
      expect(assigns[:clothes]).to eq []
    end

    pending "order by distance"
  end
end
