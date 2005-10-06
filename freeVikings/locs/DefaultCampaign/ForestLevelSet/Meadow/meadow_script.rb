# meadow_script.rb
# igneus 5.10.2005

# location script for location Meadow

require 'switch.rb'

require 'monsters/apex.rb'
require 'monsters/transporterbridge.rb'

TS = 40

# stairs with apexes:
y = 21; x = 16
while y <= 23 and x <= 19 do
  LOCATION.add_sprite(Apex.new([x*TS, y*TS], LOCATION.theme))

  x += 1
  y += 1
end

# some more apexes under the stairs:
LOCATION.add_sprite(ApexRow.new([19*TS,24*TS], 4, LOCATION.theme))

# The left 'lift' bridge:
left_bridge = TransporterBridge.new(TS*1, [TS*4,TS*21], LOCATION.theme)
LOCATION.add_sprite left_bridge

# and it's switch:
blueroom_switch = Switch.new([40*TS, 23*TS], LOCATION.theme, false,
                             Proc.new {|state|
                               if state then
                                 left_bridge.move_down
                               end
                             })
LOCATION.activeobjectmanager.add blueroom_switch

# the right 'lift' bridge:
right_bridge = TransporterBridge.new(TS*26, [TS * 4, TS * 12, TS * 25],
                                     LOCATION.theme)
right_bridge.dest = 1
LOCATION.add_sprite right_bridge
