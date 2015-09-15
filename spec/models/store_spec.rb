require 'rails_helper'

RSpec.describe Store, type: :model do
  # Due to Rails Admin
  it "should generate slug when it's an empty string" do
    chain = Chain.create!(name: 'Test Chain')
    store = Store.create!(chain: chain, slug: "", address: '4th Av', city: 'St Nowhere', state: 'GA')
    expect(store.slug).to eq 'test-chain'
  end
end
