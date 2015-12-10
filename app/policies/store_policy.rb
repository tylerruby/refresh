class StorePolicy < ApplicationPolicy
  def add?
    record.opened?
  end
end
