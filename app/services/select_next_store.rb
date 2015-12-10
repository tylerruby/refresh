class SelectNextStore
  def initialize(stores)
    self.stores = stores
  end

  def select
    store = opened_store ||
      next_closed_store ||
      stores.first
  end

  private

  attr_accessor :stores

  def opened_store
    stores.find { |store| store.opens_at && store.opened? }
  end

  def next_closed_store
    stores.drop_while { |store| store.opens_at < current_time }.first
  end

  def current_time
    @current_time ||= TimeOfDay.to_decimal(Time.current)
  end
end
