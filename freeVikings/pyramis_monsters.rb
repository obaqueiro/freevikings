# pyramis_monsters.rb
# igneus 11.3.2005
# Lokacni skript pridavajici potvory do lokace Pyramis

require 'sprite.rb'
require 'monster.rb'
require 'slug.rb'

MONSTERS = Array.new

MONSTERS.push FreeVikings::Slug.new([640,320])
