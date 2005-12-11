# meadow_script.rb
# igneus 5.10.2005

# location script for location Meadow

require 'switch.rb'

require 'door.rb'
require 'lock.rb'
require 'key.rb'
require 'apple.rb'

require 'monsters/apex.rb'
require 'monsters/transporterbridge.rb'
require 'monsters/flyingplatform.rb'
require 'monsters/arrowshooter.rb'
require 'monsters/snail.rb'

TS = LOCATION.map.class::TILE_SIZE

module Meadow
  BLUEROOM_FLOOR = 28 * TS
  LEFT_CORRIDOR_FLOOR = BLUEROOM_FLOOR - 4 * TS
  HIGH_PLATFORMS_FLOOR = 7 * TS
  GROUND = 15 * TS
end

include Meadow


# stairs with apexes:
y = (BLUEROOM_FLOOR / TS) - 4
x = 16
while y <= ((BLUEROOM_FLOOR / TS) - 1) and x <= 19 do
  LOCATION << Apex.new([x*TS, y*TS], LOCATION.theme)

  x += 1
  y += 1
end

# some more apexes under the stairs:
apexes = ApexRow.new([19*TS,BLUEROOM_FLOOR - TS], 4, LOCATION.theme)
LOCATION << apexes

# Snail in the left corridor:
snail = Snail.new([60, LEFT_CORRIDOR_FLOOR - Snail::HEIGHT])
LOCATION << snail

# The left 'lift' bridge:
left_bridge = TransporterBridge.new(TS*1, 
                                    [HIGH_PLATFORMS_FLOOR, 
                                     LEFT_CORRIDOR_FLOOR], 
                                    LOCATION.theme)
LOCATION << left_bridge

# an apple:
LOCATION << Apple.new([2*TS+5, HIGH_PLATFORMS_FLOOR - 2*TS])

# and it's switch:
blueroom_switch = Switch.new([40*TS, BLUEROOM_FLOOR - 2 * TS], 
                             LOCATION.theme, 
                             false,
                             Proc.new {|state|
                               if state then
                                 left_bridge.move_down
                               end
                             })
LOCATION << blueroom_switch

# the right 'lift' bridge:
right_bridge = TransporterBridge.new(TS*26, 
                                     [
                                       HIGH_PLATFORMS_FLOOR, 
                                       GROUND, 
                                       BLUEROOM_FLOOR
                                     ],
                                     LOCATION.theme)
LOCATION << right_bridge

# the arrowshooters which wait next to the right lift
# and shoot the passengers unless they are switched off:
shooter_1 = ArrowShooter.new([29 * TS, GROUND + 2 * TS])
LOCATION << shooter_1
shooter_2 = ArrowShooter.new([29 * TS, GROUND + 4 * TS])
LOCATION << shooter_2

# a switch which can switch both the dangerous shooters off:
shooters_switch = Switch.new([30 * TS, HIGH_PLATFORMS_FLOOR - 2 * TS],
                             LOCATION.theme,
                             true,
                             Proc.new do |state|
                               unless state
                                 shooter_1.off
                                 shooter_2.off
                               end
                             end)
LOCATION << shooters_switch

# apexes near the right shaft:
right_apexes = ApexRow.new([29*TS, GROUND-TS], 10, LOCATION.theme)
LOCATION << right_apexes

# flying platform
flying_plat = FlyingPlatform.new([
                                   [8*TS, HIGH_PLATFORMS_FLOOR],
                                   [20*TS, HIGH_PLATFORMS_FLOOR],
                                 ], 
                                 LOCATION.theme)
LOCATION << flying_plat

# the door to EXIT
exit_door = Door.new([49*TS, BLUEROOM_FLOOR-3*TS], true)
LOCATION << exit_door

# the snail which waits at the EXIT to say the vikings goodbye
exit_snail = Snail.new([53*TS, BLUEROOM_FLOOR - Snail::HEIGHT])
LOCATION << exit_snail

# lock which opens the door
exit_lock = Lock.new([47.5*TS, BLUEROOM_FLOOR-2*TS],
                     Proc.new {
                       exit_door.open 
                     },
                     Lock::BLUE)
LOCATION << exit_lock

# a key to the lock
exit_key = Key.new([45*TS, HIGH_PLATFORMS_FLOOR-2*TS], Key::BLUE)
LOCATION << exit_key

# flying platform which gives you a lift to the key (and into some dangerous
# places too)
fly_to_key = FlyingPlatform.new([
                                  [32*TS, HIGH_PLATFORMS_FLOOR],
                                  [51*TS, HIGH_PLATFORMS_FLOOR],
                                  [51*TS, HIGH_PLATFORMS_FLOOR + 5*TS],
                                  [51*TS, HIGH_PLATFORMS_FLOOR]
                                ],
                                LOCATION.theme)
LOCATION << fly_to_key

# arrowshooters who will clobber those who didn't left the flying platform
# at the right time:
shooter_3 = ArrowShooter.new([55 * TS, HIGH_PLATFORMS_FLOOR - 2*TS])
LOCATION << shooter_3
