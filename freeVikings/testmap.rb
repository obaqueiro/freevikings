# testmap.rb
# igneus 13.2.2005

# Sada testovych pripadu pro tridu Map

require 'rubyunit'
require 'RUDL'

require 'map.rb'
require 'maploadstrategy.rb'
require 'tiletype.rb'
require 'mockclasses.rb'

include FreeVikings
include FreeVikings::Mock

class TestMap < RUNIT::TestCase

  def setup
    @map = Map.new(TestingMapLoadStrategy.new)
  end

  attach_setup :setup

  def testGetSolidBlock
    assert @map.blocks_on_square([0,0,50,50])[0].solid, "The first block in tho top left corner is solid. I made it solid."
  end

  def testGetAllCollidingBlocks
    ts = Map::TILE_SIZE
    assert_equal 4, @map.blocks_on_square([ts-2, ts-2, ts, ts]).size, "Defined square collides with four tiles."
  end

  def testGetBlockOutOfLocation
    assert_exception(RuntimeError, "Block is out of map, it should not be returned.") {
      @map.blocks_on_square([Map::TILE_SIZE*5, Map::TILE_SIZE * 8, 60, 60])
    }
  end
end
