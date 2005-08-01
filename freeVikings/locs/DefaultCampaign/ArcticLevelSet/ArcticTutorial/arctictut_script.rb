# arctictut_script.rb
# igneus 26.7.2005

# Script for location Arctic Tutorial.

require 'helpbutton.rb'

#=== ACTIVE OBJECTS:

help_data = []

help_data << [FreeVikings::Rectangle.new(180,320,30,30), 
              "Press Ctrl or PgUp to switch between the vikings."]

help_data.each do |h|
  help = FreeVikings::HelpButton.new(h[0], h[1], LOCATION)
  LOCATION.add_active_object help
end

#=== MONSTERS:
