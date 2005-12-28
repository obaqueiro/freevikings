# antarcticvisitors_script.rb
# igneus 23.10.2005

# Script of the overcrowded location full of penguins.

require 'monsters/lift.rb'
require 'monsters/penguin.rb'
require 'monsters/apex.rb'
require 'door.rb'
require 'lock.rb'
require 'key.rb'
require 'switch.rb'

include FreeVikings

# if FUNLESS is true, switches off any non-important
# processor time eating monsters (e.g. dozens of penguins).
FUNLESS = false

TS = LOCATION.map.class::TILE_SIZE

# -- EXIT AREA --
# EXIT is closed behind the locked door.

exit_door = Door.new [31*TS-Door::WIDTH, 9*TS-Door::HEIGHT]
LOCATION << exit_door

exit_lock = Lock.new([32*TS+5, 9*TS-60], Proc.new { exit_door.open })
LOCATION << exit_lock

# -- TOP CORRIDOR --
# The vikings start here, in the corridor full of pinguins.

# - lifts:
# The left lift is a bit dangerous because it can get you onto the apexes
# and then you die pierced.
left_lift = Lift.new TS, 
                     [4*TS, 9*TS, 15*TS, 22*TS], 
                     LOCATION.theme
LOCATION << left_lift
exit_lift = Lift.new 31*TS, [4*TS, 9*TS, 16*TS], LOCATION.theme
LOCATION << exit_lift

# - pinguins:
unless FUNLESS
  15.step(30,3) do |i|
    LOCATION << Penguin.new([i*TS, 4*TS-Penguin::HEIGHT])
  end
end

# -- THE WEST SIDE -- :o)
# You can find here some pretty sharp apexes and also the red key you
# need if you want to get to another level. This area is Olaf's job mainly,
# but the other vikings are also needed, of course.

# apexes under the left lift:
liftspace_apexes = ApexRow.new [1*TS, 11*TS], 3, LOCATION.theme
LOCATION << liftspace_apexes

# more apexes under the left lift:
more_liftspace_apexes = ApexRow.new [1*TS, 17*TS], 3, LOCATION.theme
LOCATION << more_liftspace_apexes

# "interapex-switch" - Baleog must switch it to free the path to Olaf
interapex_switch = Switch.new([2, 14*TS+5],
                              LOCATION.theme,
                              true,
                              Proc.new { more_liftspace_apexes.destroy })
LOCATION << interapex_switch

# Olaf's switch. He must switch it to open Baleog the path to the
# interapex switch.
olafs_switch = Switch.new([2*TS+2, 20*TS],
                          LOCATION.theme,
                          true,
                          Proc.new { liftspace_apexes.destroy })
LOCATION << olafs_switch

# hidden blue key (only Erik can pick it without going stucked)
blue_key = Key.new [7*TS+5, 16*TS], Key::BLUE
LOCATION << blue_key

# apexes in Olaf's way:
needles_for_Olaf = ApexRow.new [11*TS, 15*TS], 3, LOCATION.theme
LOCATION << needles_for_Olaf
another_needles = ApexRow.new [14*TS, 20*TS], 3, LOCATION.theme
LOCATION << another_needles

# door behind which the red key is hidden
red_key_door = Door.new [20*TS, 13*TS]
LOCATION << red_key_door

# blue lock which locks them
blue_lock = Lock.new([18*TS, 14*TS],
                     Proc.new { red_key_door.open },
                     Lock::BLUE)
LOCATION << blue_lock

# the red key (needed to reach EXIT)
red_key = Key.new [22*TS, 14*TS], Key::RED
LOCATION << red_key
