require 'rails_helper'

RSpec.describe Store, type: :model do
  let(:store) { build(:store) }

  describe "associations" do
    it { is_expected.to have_one(:address).dependent(:destroy) }
  end

  it { is_expected.to accept_nested_attributes_for(:address).allow_destroy(true) }

  it { is_expected.to delegate_method(:full_address).to(:address) }
  it { is_expected.to delegate_method(:coordinates).to(:address) }

  # Due to Rails Admin
  it "generates slug when it's an empty string" do
    store = create(:store, name: 'Test Store', slug: '')
    expect(store.slug).to eq 'test-store'
  end
  
  describe "#opened?" do
    let(:opened_store) { create :store, human_opens_at: '09:00', human_closes_at: '11:00' }
    let(:closed_store) { create :store, human_opens_at: '11:00', human_closes_at: '13:00' }

    before do
      Timecop.travel Time.zone.parse('10:00')
    end

    it { expect(opened_store).to be_opened }
    it { expect(closed_store).not_to be_opened }

    it "works during extra hours" do
      Timecop.travel Time.zone.parse('02:00')
      store = create :store, human_opens_at: '22:00', human_closes_at: '03:00'
      expect(store).to be_opened
    end
  end

  describe '.default_scope' do
    let!(:later_store) do
      create :store,
             human_opens_at: '14:00',
             human_closes_at: '16:00',
             created_at: 1.hour.ago
    end
    let!(:earlier_store) do
      create :store,
             human_opens_at: '09:00',
             human_closes_at: '11:00',
             created_at: 1.hour.from_now
    end

    it { expect(Store.all).to eq [earlier_store, later_store] }
  end

  describe ".by_city" do
    let!(:city) { create(:city, name: 'Atlanta') }
    let!(:address) { create(:address, city: city) }
    let!(:store) { create(:store, address: address) }

    it { expect(Store.by_city('Atlanta')).to eq [store] }
    it { expect(Store.by_city('atlanta')).to eq [store] }
  end

  describe ".order_by_distance" do
    before do
      Geocoder::Lookup::Test.add_stub("closer address, Atlanta, GA", [
        {
          'latitude'     => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => 'closer address, Atlanta, GA',
          'state'        => 'Georgia',
          'state_code'   => 'GA',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ])

      Geocoder::Lookup::Test.add_stub("further address, Atlanta, GA", [
        {
          'latitude'     => 40.9999999,
          'longitude'    => -74.9999999,
          'address'      => 'further address, Atlanta, GA',
          'state'        => 'Georgia',
          'state_code'   => 'GA',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ])
    end

    let!(:further_address) { create(:address, address: 'further address') }
    let!(:further_store) { create(:store, address: further_address) }

    let!(:closer_address) { create(:address, address: 'closer address') }
    let!(:closer_store) { create(:store, address: closer_address) }

    it do
      expect(Store.order_by_distance('4th Av., Atlanta, GA'))
      .to eq [closer_store, further_store]
    end
  end

  describe ".opened" do
    before do
      Geocoder::Lookup::Test.add_stub("far far away, Atlanta, GA", [
        {
          'latitude'     => 50,
          'longitude'    => -80,
          'address'      => 'far far away, Atlanta, GA',
          'state'        => 'Georgia',
          'state_code'   => 'GA',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ])
    end

    # let!(:far_away_store)  { create :store, name: 'Far Away Store',  address: create(:address, address: 'far far away') }
    let!(:fulltime_store)  { create :store, name: 'Full Time Store' }
    let!(:morning_store)   { create :store, name: 'Morning Store',   human_opens_at: '05:00', human_closes_at: '15:00' }
    let!(:afternoon_store) { create :store, name: 'Afternoon Store', human_opens_at: '15:00', human_closes_at: '21:00' }
    let!(:night_store)     { create :store, name: 'Night Store',     human_opens_at: '21:00', human_closes_at: '03:00' }
    let(:opened_stores) { Store.opened.map(&:name) }

    context 'when 1:00' do
      before { Timecop.travel Time.zone.parse('01-01-2016 01:00') }
      it { expect(opened_stores).to eq [night_store.name, fulltime_store.name] }
    end

    context 'when 9:00' do
      before { Timecop.travel Time.zone.parse('01-01-2016 09:00') }
      it { expect(opened_stores).to eq [morning_store.name, fulltime_store.name] }
    end

    context 'when 15:00' do
      before { Timecop.travel Time.zone.parse('01-01-2016 15:00') }
      it { expect(opened_stores).to eq [afternoon_store.name, fulltime_store.name] }
    end

    context 'when 21:00' do
      before { Timecop.travel Time.zone.parse('01-01-2016 21:00') }
      it { expect(opened_stores).to eq [night_store.name, fulltime_store.name] }
    end
  end

  describe '#human_opens_at' do
    it 'formats decimal to string' do
      store.opens_at = 9.5
      expect(store.human_opens_at).to eq '09:30'
    end
  end

  describe '#human_closes_at' do
    it 'formats decimal to string' do
      store.closes_at = 9.5
      expect(store.human_closes_at).to eq '09:30'
    end
  end

  describe 'parses human-readable times to decimals on validation' do
    context 'correctly parsing time' do
      let(:store) { build(:store, human_opens_at: '21:30', human_closes_at: '05:00') }

      before do
        expect(store).to be_valid
      end

      it { expect(store.opens_at).to eq 21.5 }
      it { expect(store.closes_at).to eq 29.0 }
    end

    context 'incorrectly parsing time' do
      let(:store) { build(:store, human_opens_at: '21:60', human_closes_at: '05:60') }

      before do
        expect(store).not_to be_valid
      end

      it { expect(store.errors).to include :opens_at }
      it { expect(store.errors).to include :closes_at }
    end
  end
end
