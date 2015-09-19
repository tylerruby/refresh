require 'rails_helper'

RSpec.describe Store, type: :model do
  # Due to Rails Admin
  it "should generate slug when it's an empty string" do
    chain = create(:chain, name: 'Test Chain')
    store = create(:store, chain: chain, slug: "")
    expect(store.slug).to eq 'test-chain'
  end
end
