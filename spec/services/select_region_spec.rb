require 'rails_helper'

RSpec.describe SelectRegion do
  let(:service) { SelectRegion.new(address, regions) }
  let(:address) { create(:address, address: "My special address") }

  before do
    stub_address("My special address, Atlanta, GA", 0, 0)
  end

  context "finds one region that includes the address" do
    let(:region) { create(:region, address: address.dup) }
    let(:other_region) { create(:region) }
    let(:regions) { [other_region, region] }

    it "returns the region" do
      expect(service.region).to eq region
    end
  end

  context "doesn't find any region nearby" do
    let(:regions) { [] }

    it "returns the region" do
      expect(service.region).to be_nil
    end
  end
end
