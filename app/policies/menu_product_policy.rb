class MenuProductPolicy < ApplicationPolicy
  def add?
    return true unless user.present?
    return false unless user.current_address.present?
    return false unless record.menu.date >= Date.current
    SelectRegion.new(user.current_address).region == record.menu.region
  end
end
