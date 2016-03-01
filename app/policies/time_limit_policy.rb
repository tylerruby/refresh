class TimeLimitPolicy
  def passed_time_limit?(date)
    date.today? && Time.current.hour >= 10
  end
end
