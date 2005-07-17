# pyramis_monsters.rb
# igneus 11.3.2005
# Lokacni skript pridavajici potvory do lokace Pyramis

require 'monsters/slug.rb'
require 'apple.rb'

MONSTERS.push FreeVikings::Slug.new([640,360])

5.times { |i|
  LOCATION.add_item(FreeVikings::Apple.new([200 + i * 40, 320]))
}
