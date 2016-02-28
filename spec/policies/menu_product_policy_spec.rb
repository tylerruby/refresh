require 'rails_helper'

describe MenuProductPolicy do
  let(:guest) { GuestUser.new(address_id: create_nearby_address.id) }
  let(:guest_without_address) { GuestUser.new({}) }
  let(:user) { create(:user, current_address: create_nearby_address) }
  let(:user_without_address) { create(:user, current_address: nil) }

  let(:region_nearby_user) { create(:region, address: create_nearby_address) }
  let(:region_away_from_the_user) { create(:region, address: create_far_away_address) }

  subject { described_class }

  def create_nearby_address
    create(:address, address: 'nearby address')
  end

  def create_far_away_address
    create(:address, address: 'far away address')
  end

  before do
    stub_address('nearby address, Atlanta, GA', 10, 10)
    stub_address('far away address, Atlanta, GA', 99, 99)
  end

  permissions :add? do
    let(:available_menu_product) do
      create :menu_product, menu: create(:menu,
                                    date: Date.current,
                                    region: region_nearby_user
                                  )
    end
    let(:menu_product_from_far_away) do
      create :menu_product, menu: create(:menu,
                                    date: Date.current,
                                    region: region_away_from_the_user
                                  )
    end
    let(:menu_product_from_yesterday) do
      create :menu_product, menu: create(:menu,
                                    date: Date.yesterday,
                                    region: region_nearby_user
                                  )
    end

    it { is_expected.to permit(guest, available_menu_product) }
    it { is_expected.not_to permit(guest, menu_product_from_far_away) }
    it { is_expected.not_to permit(guest, menu_product_from_yesterday) }

    it { is_expected.not_to permit(guest_without_address, available_menu_product) }
    it { is_expected.not_to permit(guest_without_address, menu_product_from_far_away) }
    it { is_expected.not_to permit(guest_without_address, menu_product_from_yesterday) }

    it { is_expected.to permit(user, available_menu_product) }
    it { is_expected.not_to permit(user, menu_product_from_far_away) }
    it { is_expected.not_to permit(user, menu_product_from_yesterday) }

    it { is_expected.not_to permit(user_without_address, available_menu_product) }
    it { is_expected.not_to permit(user_without_address, menu_product_from_far_away) }
    it { is_expected.not_to permit(user_without_address, menu_product_from_yesterday) }
  end
end
