module ProductHelper
  def format_24_to_am_pm(time)
    Time.parse(time).strftime('%H:%M%P')
  end
end
