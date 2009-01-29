# fllspitter_script.rb
# igneus 29.1.2009

require 'fireballspitter.rb'

TS = LOCATION.map.tile_size
LOCATION << FireballSpitter.new([TS, 11*TS-80])
LOCATION << FireballSpitter.new([13*TS, 7*TS-80], :left)
