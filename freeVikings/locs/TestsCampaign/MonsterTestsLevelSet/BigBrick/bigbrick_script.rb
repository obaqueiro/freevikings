# bigbrick_script.rb
# igneus 9.2.2009

require 'bigbrick.rb'
require 'ladder'

TS = LOCATION.map.tile_size

[
 # BigBrick.new([5*TS, 2*TS-2]),
 BigBrick.new([5*TS, 4*TS-1]),
 BigBrick.new([8*TS, 8*TS-1])
].each {|b|
  LOCATION << b
}

LOCATION << Ladder.new([400,240],4)
