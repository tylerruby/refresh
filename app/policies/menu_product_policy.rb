class MenuProductPolicy < ApplicationPolicy
  def add?
    return false unless user.current_address.present?
    return false if record.menu.date.past?
    return false if passed_time_limit?(record.menu.date)
    SelectRegion.new(user.current_address).region == record.menu.region
  end

  private

    def passed_time_limit?(date)
      TimeLimitPolicy.new.passed_time_limit?(date)
    end
end
