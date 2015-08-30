# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Store.create!([
  { name: 'Lululemon Athletica', address: '1168 Howell Mill Rd', city: 'Atlanta', state: 'GA' },
  { name: 'Express',             address: '230 18th Street',     city: 'Atlanta', state: 'GA' },
  { name: 'The Clothing Warehouse', address: '420 Moreland Ave NE', city: 'Atlanta', state: 'GA' },
  { name: 'Richards Variety Store', address: '2347 Peachtree Rd', city: 'Atlanta', state: 'GA' },
  { name: 'Value Village Thrift Store', address: '1374 Moreland Ave SE', city: 'Atlanta', state: 'GA' }
])
