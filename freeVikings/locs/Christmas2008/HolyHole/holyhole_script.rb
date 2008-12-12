# holyhole_script.rb
# 12.12.2008

require 'wall'
require 'ladder'

TS = LOCATION.map.tile_size

# Walls in the secret "bonus way"
LOCATION << Wall.new([17*TS, 34*TS], 6, 1, LOCATION)
LOCATION << Wall.new([16*TS, 42*TS], 1, 3, LOCATION)

# Ladder in the big cave
LOCATION << Ladder.new([46*TS,61*TS], 13)
