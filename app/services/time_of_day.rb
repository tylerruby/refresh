class TimeOfDay
  def self.to_decimal(time)
    new(time).to_decimal
  end

  def self.to_string(time)
    new(time).to_string
  end

  def initialize(time)
    self.time = time
  end

  def to_decimal
    # Creating a BigDecimal manually because Rails accessor is assigning wrong value.
    BigDecimal.new((time.hour + (time.min.to_f / 60)).to_s)
  end

  def to_string
    return unless time
    time.strftime '%H:%M'
  end

  private

  attr_accessor :time

  def create_time_at(decimal)
    Time.new.beginning_of_day + decimal.hours
  end

  def time
    return unless @time

    case @time
    when Time then @time
    when String then @time.to_time
    when Numeric then create_time_at(@time)
    else fail "Cannot cast Time from #{@time.inspect}"
    end
  end
end
