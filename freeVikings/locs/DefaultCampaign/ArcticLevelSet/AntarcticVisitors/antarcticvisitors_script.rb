# antarcticvisitors_script.rb
# igneus 23.10.2005

# Script of the overcrowded location full of penguins.

require 'monsters/transporterbridge.rb'
require 'monsters/penguin.rb'
require 'door.rb'
require 'lock.rb'

TS = LOCATION.map.class::TILE_SIZE

# -- EXIT AREA --
# EXIT is closed behind the locked door.

exit_door = Door.new [31*TS-Door::WIDTH, 9*TS-Door::HEIGHT]
LOCATION.map.static_objects.add exit_door

exit_lock = Lock.new([32*TS+5, 9*TS-60], Proc.new {})
LOCATION.map.static_objects.add exit_lock

# -- TOP CORRIDOR --
# The vikings start here. The corridor is full of pinguins.

# lifts:
left_lift = TransporterBridge.new TS, [4*TS, 9*TS], LOCATION.theme
LOCATION.add_sprite left_lift
exit_lift = TransporterBridge.new 31*TS, [4*TS, 9*TS], LOCATION.theme
LOCATION.add_sprite exit_lift

# pinguins:
6.step(30,3) do |i|
  LOCATION.add_sprite Penguin.new([i*TS, 4*TS-Penguin::HEIGHT])
end
