# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Chain.create!([
  { name: 'Lululemon Athletica', stores: [Store.new(address: '1168 Howell Mill Rd', city: 'Atlanta', state: 'GA')] },
  { name: 'Express', stores: [Store.new(address: '230 18th Street',     city: 'Atlanta', state: 'GA')] },
  { name: 'The Clothing Warehouse', stores: [Store.new(address: '420 Moreland Ave NE', city: 'Atlanta', state: 'GA')] },
  { name: 'Richards Variety Store', stores: [Store.new(address: '2347 Peachtree Rd', city: 'Atlanta', state: 'GA')] },
  { name: 'Value Village Thrift Store', stores: [Store.new(address: '1374 Moreland Ave SE', city: 'Atlanta', state: 'GA')] },
  { name: "It's Fashion", stores: [Store.new(address: '6385 Old National Hwy', city: 'Atlanta', state: 'GA')] }
])

User.create!(email: ENV['ADMIN_EMAIL'] || 'name@example.com', password: ENV['ADMIN_PASSWORD'] || '12345678')
