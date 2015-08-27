class Store < ActiveRecord::Base
  geocoded_by :address
  after_validation :geocode, if: -> { address.present? and address_changed? }
end
