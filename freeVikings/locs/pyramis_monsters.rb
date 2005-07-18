# pyramis_monsters.rb
# igneus 11.3.2005
# Lokacni skript pridavajici potvory do lokace Pyramis

require 'monsters/slug.rb'
require 'apple.rb'
require 'helpbutton.rb'

MONSTERS.push FreeVikings::Slug.new([640,360])

5.times { |i|
  LOCATION.add_item(FreeVikings::Apple.new([200 + i * 40, 320]))
}

erik_help = HelpButton.new(Rectangle.new(400, 360, 30, 30), 
                           "The viking in a red dress is called Erik. "\
                           "He can jump high. Press space to try it.", 
                           LOCATION)
LOCATION.add_active_object erik_help
