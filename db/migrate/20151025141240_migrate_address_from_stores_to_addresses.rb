class MigrateAddressFromStoresToAddresses < ActiveRecord::Migration
  def up
    city = City.create!(name: 'Atlanta', state: 'GA')
    Store.find_each do |store|
      Address.create!(address: store[:address], city: city, addressable: store)
    end
  end
end
