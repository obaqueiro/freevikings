# testmap.rb
# igneus 13.2.2005

# Sada testovych pripadu pro tridu Map

require 'rubyunit'
require 'RUDL'

require 'map.rb'
require 'locationloadstrategy.rb'
require 'tiletype.rb'

include FreeVikings

class TestMap < RUNIT::TestCase

  def setup
    @map = Map.new(XMLLocationLoadStrategy.new("../locs/pyramida_loc.xml"))
  end

  def testGetSolidBlock
    assert @map.blocks_on_square([0,0,50,50])[0].solid, "The first block in tho top left corner is solid. I made it solid."
  end

  def testGetBlockByIndex
    assert_not_nil @map.block_by_indexes(1,1), "The block on indexes 0,0 must not be nil."
  end


  def testGetAllCollidingBlocks
    ts = Map::TILE_SIZE
    assert_equal 4, @map.blocks_on_square([ts-2, 2*ts-2, ts, ts]).size, "Defined square collides with four tiles."
  end

  def testGetBlockOutOfLocation
    assert_exception(RuntimeError, "Block is out of map, it should not be returned.") {
      @map.blocks_on_square([Map::TILE_SIZE*15, Map::TILE_SIZE * 15, 60, 60])
    }
  end

end # class TestMap
