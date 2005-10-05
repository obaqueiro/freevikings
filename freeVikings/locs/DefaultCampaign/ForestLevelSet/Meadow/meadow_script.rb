# meadow_script.rb
# igneus 5.10.2005

# location script for location Meadow

require 'monsters/apex.rb'

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
