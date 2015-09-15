require 'rails_helper'

RSpec.describe Chain, type: :model do
  let(:chain) { Chain.create!(name: "Test Chain") }

  it "destroys child stores when destroying chain" do
    Store.create!(chain: chain, address: '4th Av', city: 'St Nowhere', state: 'GA')
    expect { chain.destroy }.to change { Store.count }.by(-1)
  end

  it "destroys child clothes when destroying chain" do
    Cloth.create!(chain: chain, name: 'Hoodie', price: 99.99)
    expect { chain.destroy }.to change { Cloth.count }.by(-1)
  end
end
