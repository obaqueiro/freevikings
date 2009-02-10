# bigbrick_script.rb
# igneus 9.2.2009

require 'bigbrick.rb'

TS = LOCATION.map.tile_size

[
 BigBrick.new([5*TS, 2*TS-2]),
 BigBrick.new([5*TS, 4*TS]),
 BigBrick.new([8*TS, 8*TS])
].each {|b|
  LOCATION << b
}