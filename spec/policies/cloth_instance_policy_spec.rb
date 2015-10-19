require 'rails_helper'

describe ClothInstancePolicy do
  subject { described_class }

  permissions :add? do
    let(:store) { create(:store) }

    it "denies access if store isn't available for delivery" do
      allow(store).to receive(:available_for_delivery?).and_return(false)
      expect(subject).not_to permit(User.new, build(:cloth_instance, store: store))
    end

    it "grants access if store is available for delivery " do
      allow(store).to receive(:available_for_delivery?).and_return(true)
      expect(subject).to permit(User.new, build(:cloth_instance, store: store))
    end
  end
end
