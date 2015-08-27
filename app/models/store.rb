class Store < ActiveRecord::Base
  geocoded_by :address
  # TODO: validate presence of attributes
  # TODO: test that this request is only sent in these cases
  after_validation :geocode, if: -> { address.present? and address_changed? }
end
