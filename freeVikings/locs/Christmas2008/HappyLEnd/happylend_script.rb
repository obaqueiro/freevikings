# happylend_script.rb
# igneus 22.12.2008

require 'ladder'

TS = LOCATION.map.tile_size

LOCATION << Ladder.new([50, 9*TS], 10)
