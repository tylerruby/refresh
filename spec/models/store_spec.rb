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

  describe ".available_for_delivery" do
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

    let!(:store_available_for_delivery) { create(:store) }
    let!(:store_not_available_for_delivery) do
      create(:store, address: create(:address, address: 'far far away'))
    end

    it do
      expect(Store.available_for_delivery('4th Av., Atlanta, GA'))
      .to eq [store_available_for_delivery]
    end
  end
end
