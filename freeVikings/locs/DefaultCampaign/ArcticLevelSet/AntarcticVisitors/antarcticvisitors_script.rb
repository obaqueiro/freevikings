# antarcticvisitors_script.rb
# igneus 23.10.2005

# Script of the overcrowded location full of penguins.

require 'monsters/transporterbridge.rb'
require 'monsters/penguin.rb'
require 'monsters/apex.rb'
require 'door.rb'
require 'lock.rb'

# if FUNLESS is true, switches off any non-important
# processor time eating monsters (e.g. dozens of penguins).
FUNLESS = false

TS = LOCATION.map.class::TILE_SIZE

# -- EXIT AREA --
# EXIT is closed behind the locked door.

exit_door = Door.new [31*TS-Door::WIDTH, 9*TS-Door::HEIGHT]
LOCATION.map.static_objects.add exit_door

exit_lock = Lock.new([32*TS+5, 9*TS-60], Proc.new {})
LOCATION.map.static_objects.add exit_lock

# -- TOP CORRIDOR --
# The vikings start here, in the corridor full of pinguins.

# - lifts:
# The left lift is a bit dangerous because it can get you onto the apexes
# and then you die pierced.
left_lift = TransporterBridge.new TS, [4*TS, 9*TS, 11*TS], LOCATION.theme
LOCATION.add_sprite left_lift
exit_lift = TransporterBridge.new 31*TS, [4*TS, 9*TS], LOCATION.theme
LOCATION.add_sprite exit_lift

# - pinguins:
unless FUNLESS
  6.step(30,3) do |i|
    LOCATION.add_sprite Penguin.new([i*TS, 4*TS-Penguin::HEIGHT])
  end
end

# -- THE WEST SIDE -- :o)

# apexes under the left lift:
#apexes = ApexRow.new [1*TS, 11*TS], 3, LOCATION.theme
#LOCATION.add_sprite apexes
