require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:address) { build(:address) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:addressable) }
  end

  describe "#full_address" do
    it { expect(address.full_address).to eq "4th Av., Atlanta, GA" }

    context 'when address_2 is present' do
      before { address.address_2 = '2º floor' }

      it { expect(address.full_address).to eq "4th Av., 2º floor, Atlanta, GA" }
    end
  end

  describe "#coordinates" do
    it { expect(address.coordinates).to eq [address.latitude, address.longitude] }
  end

  describe "geocoder" do
    it "geocodes before validation" do
      expect(address.latitude).to be_nil
      expect(address.longitude).to be_nil

      address.valid?

      expect(address.latitude).to be 40.7143528
      expect(address.longitude).to be -74.0059731
    end

    it "doesn't geocodes if creating an address with default coordinates" do
      address.latitude = 1.0
      address.longitude = 1.0

      address.valid?

      expect(address.latitude).to be 1.0
      expect(address.longitude).to be 1.0
    end
  end

  describe ".order_by_distance" do
    before do
      stub_address("closer address, Atlanta, GA", 40.7143528, -74.0059731)
      stub_address("further address, Atlanta, GA", 40.9999999, -74.9999999)
    end

    let!(:further_address) { create(:address, address: 'further address') }
    let!(:closer_address) { create(:address, address: 'closer address') }

    it do
      expect(Address.order_by_distance('4th Av., Atlanta, GA'))
      .to eq [closer_address, further_address]
    end
  end
end
