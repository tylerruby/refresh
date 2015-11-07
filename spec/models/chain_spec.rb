require 'rails_helper'

RSpec.describe Chain, type: :model do
  let(:chain) { create(:chain, name: "Test Chain") }

  it "destroys child stores when destroying chain" do
    create(:store, chain: chain)
    expect { chain.destroy }.to change { Store.count }.by(-1)
  end
end
