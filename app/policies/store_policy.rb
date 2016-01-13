class StorePolicy < ApplicationPolicy
  def add?
    record.opened? &&
      (
        !user ||
        user.current_address &&
        record.available_for_delivery_on?(user.current_address.full_address)
      )
  end
end
