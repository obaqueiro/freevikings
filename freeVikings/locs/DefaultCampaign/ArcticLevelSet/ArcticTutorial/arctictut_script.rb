# arctictut_script.rb
# igneus 26.7.2005

# Script for location Arctic Tutorial.

require 'helpbutton.rb'
require 'monsters/apex.rb'

include FreeVikings

#=== ACTIVE OBJECTS:

help_data = []

help_data << [FreeVikings::Rectangle.new(180,320,30,30), 
              "Press Ctrl or PgUp to switch between the vikings."]
help_data << [Rectangle.new(20*40, 320, 30, 30),
              "The guy in the red clothes is called Erik. He can jump. Try to press SPACE."]

help_data.each do |h|
  help = FreeVikings::HelpButton.new(h[0], h[1], LOCATION)
  LOCATION.add_active_object help
end

#=== MONSTERS:

# Some apexes:
def create_apex(x,y)
  a = Apex.new Rectangle.new(x, y, 40, 40), LOCATION.theme
  LOCATION.add_sprite a
end

apex_positions = []
y = 12*40
(21*40).step(25*40, 40) {|x| create_apex(x,y)}
(28*40).step(32*40, 40) {|x| create_apex(x,y)}


LOCATION.add_sprite a
