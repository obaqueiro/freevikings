# bomb_script.rb
# igneus 31.10.2008

# Map for testing of Bomb

require 'bomb.rb'
require 'wall.rb'

TS = TILE_SIZE = 40
IS = ITEM_SIZE = 40

FLOOR = 11*TS

# huge heap of bombs :)
(8**2).times {|i|
  col = i % 8
  row = i / 8

  x = 400 + col * IS
  y = (FLOOR - 20) - row * IS

  LOCATION << Bomb.new([x,y])
}

# wall
LOCATION << Wall.new([1000, FLOOR-4*TS], 2, 4)
