# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

atlanta = City.create!(name: 'Atlanta', state: 'GA')

address = {
  city: atlanta,
  address: 'Georgia Tech, North Ave NW, Atlanta, GA, USA'
}

Store.create! [
  {
    name: 'Breakfast',
    human_opens_at: '05:00',
    human_closes_at: '11:00',
    address: Address.new(address)
  },
  {
    name: 'Lunch',
    human_opens_at: '11:00',
    human_closes_at: '18:00',
    address: Address.new(address)
  },
  {
    name: 'Dinner',
    human_opens_at: '18:00',
    human_closes_at: '05:00',
    address: Address.new(address)
  },
  {
    name: 'General Store',
    address: Address.new(address)
  }
]
