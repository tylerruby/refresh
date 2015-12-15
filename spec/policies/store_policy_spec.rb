require 'rails_helper'

describe StorePolicy do

  let(:guest) { nil }
  let(:user) { create(:user, current_address: create_address) }

  subject { described_class }

  def create_address
    create(:address, address: 'nearby address')
  end

  before do
    stub_address('nearby address, Atlanta, GA', 10, 10)
    stub_address('far away address, Atlanta, GA', 99, 99)
  end

  permissions :add? do
    let(:opened_store) do
      create :store,
        human_opens_at: '09:00',
        human_closes_at: '11:00',
        address: create_address
    end
    let(:closed_store) do
      create :store,
        human_opens_at: '14:00',
        human_closes_at: '16:00',
        address: create_address
    end
    let(:far_away_store) do
      create :store,
        human_opens_at: '09:00',
        human_closes_at: '11:00',
        address: create(:address, address: 'far away address')
    end

    before do
      Timecop.travel Time.zone.parse('10:00')
    end

    it { is_expected.to permit(guest, opened_store) }
    it { is_expected.not_to permit(guest, closed_store) }

    # TODO: Find a way to block guest user (probably creating a Guest class)
    it { is_expected.to permit(guest, far_away_store) }

    it { is_expected.to permit(user, opened_store) }
    it { is_expected.not_to permit(user, closed_store) }
    it { is_expected.not_to permit(user, far_away_store) }
  end
end
