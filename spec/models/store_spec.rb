require 'rails_helper'

RSpec.describe Store, type: :model do
  let(:store) { build(:store) }

  # Due to Rails Admin
  it "generates slug when it's an empty string" do
    chain = create(:chain, name: 'Test Chain')
    store = create(:store, chain: chain, slug: "")
    expect(store.slug).to eq 'test-chain'
  end

  it "overrides the chain's name" do
    chain = create(:chain, name: 'Test Chain')
    store = create(:store, chain: chain)
    expect(store.name).to eq chain.name
    store.name = "Some Store"
    expect(store.name).to eq "Some Store"
  end

  it "delegates the logo to the chain's logo" do
    expect(store.logo).to eq store.chain.logo
  end 

  it "strips city from surrounding empty space" do
    store.city = '  New York  '
    expect(store.city).to eq 'New York'
  end
end
