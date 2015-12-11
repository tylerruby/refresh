require 'rails_helper'

RSpec.describe StoresController, type: :controller do
  before do
    stub_address("4th Av., Atlanta, GA", 40.7143528, -74.0059731)
    stub_address("3905 Mike Padgett Hwy, Atlanta, GA", 33.353523, -81.982439)
  end

  describe "GET #search_by_city"  do
    let(:atlanta) { create(:city, name: 'Atlanta') }

    def available_address
      create :address, city: atlanta, address: '3905 Mike Padgett Hwy'
    end

    let(:current_address) do
      available_address
    end

    let!(:available_store) do
      create :store,
        human_opens_at: '21:00', human_closes_at: '03:00',
        address: available_address
    end

    let!(:unavailable_store) do
      create :store,
        address: create(:address, city: atlanta, address: '4th Av.')
    end

    let!(:unavailable_store_by_time) do
      create :store,
        human_opens_at: '05:00', human_closes_at: '15:00',
        address: available_address
    end

    let(:atlanta) { create(:city, name: 'Atlanta') }

    let!(:store_in_another_city) do
      create :store, address: create(:address, city: atlanta)
    end

    def do_action
      get :search_by_city, city: 'atlanta'
    end

    before do
      Timecop.travel Time.zone.parse('01-01-2016 01:00')

      allow_any_instance_of(Store).to receive(:available_for_delivery?).and_return(true)
      allow_any_instance_of(ApplicationController)
        .to receive(:current_address).and_return(current_address)
    end

    it "sets the city's name" do
      do_action
      expect(assigns[:city]).to eq 'Atlanta'
    end

    it 'redirect to open store' do
      do_action
      expect(subject).to redirect_to action: :show, id: available_store.slug
    end

    context "there's no store opened" do
      it "redirects to the next store to be opened during normal hours" do
        Timecop.travel Time.zone.parse('01-01-2016 20:00')
        do_action
        expect(subject).to redirect_to action: :show, id: available_store.slug
      end

      it "redirects to the next store to be opened during extra hours" do
        Timecop.travel Time.zone.parse('01-01-2016 04:00')
        do_action
        expect(subject).to redirect_to action: :show, id: unavailable_store_by_time.slug
      end

      it "redirects to the first store when after all stores closed" do
        Store.destroy_all
        closed_store = create :store,
                              human_opens_at: '09:00',
                              human_closes_at: '11:00',
                              address: available_address
        Timecop.travel Time.zone.parse('01-01-2016 12:00')
        do_action
        expect(subject).to redirect_to action: :show, id: closed_store.slug
      end
    end

    pending "order by distance"
  end

  describe "GET #show" do
    let(:atlanta) { create(:city, name: 'Atlanta') }
    let!(:store) { create(:store, address: create(:address, city: atlanta)) }
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
