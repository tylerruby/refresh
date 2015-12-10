require 'rails_helper'

describe StorePolicy do

  let(:anyone) { User.new }

  subject { described_class }

  permissions :add? do
    let(:opened_store) do
      create :store,
             human_opens_at: '09:00',
             human_closes_at: '11:00'
    end
    let(:closed_store) do
      create :store,
             human_opens_at: '14:00',
             human_closes_at: '16:00'
    end

    before do
      Timecop.travel Time.zone.parse('10:00')
    end

    it { is_expected.to permit(anyone, opened_store) }
    it { is_expected.not_to permit(anyone, closed_store) }
  end
end
