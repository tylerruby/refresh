class SelectMenuDates

  HOLIDAYS = [
    '2016-01-01', # New Year's Day
    '2016-02-15', # Presidents Day
    '2016-05-30', # Memorial Day
    '2016-07-04', # Independence Day
    '2016-09-05', # Labor Day
    '2016-11-24', # Thanksgiving Holiday
    '2016-11-25', # Thanksgiving Holiday
    '2016-12-26', # Winter Holiday Break
    '2016-12-27', # Winter Holiday Break
    '2016-12-28', # Winter Holiday Break
    '2016-12-29', # Winter Holiday Break
    '2016-12-30', # Winter Holiday Break
  ].map(&:to_date)

  def initialize(date)
    self.date = date
  end

  def dates
    (date..date + 6.days)
      .reject(&weekend?)
      .reject(&holiday?)
      .reject(&passed_time_limit?)
  end

  private

    attr_accessor :date

    def weekend?
      -> (date) { date.saturday? || date.sunday? }
    end

    def holiday?
      -> (date) { HOLIDAYS.include?(date) }
    end

    def passed_time_limit?
      TimeLimitPolicy.new.method(:passed_time_limit?)
    end
end
