# testmap.rb
# igneus 13.2.2005

# Sada testovych pripadu pro tridu Map

require 'testtilesowner.rb'

require 'map.rb'
require 'locationloadstrategy.rb'
require 'tiletype.rb'
require 'mockclasses.rb'

class TestMap < TestTilesOwner

  include FreeVikings

  def setup
    @map = Map.new(Mock::TestingMapLoadStrategy.new)
  end

  def testGetSolidBlock
    assert @map.blocks_on_square([0,0,50,50])[0].solid, "The first block in tho top left corner is solid. I made it solid."
  end

  def testAreaFree
    assert_equal nil, @map.area_free?([0,0,50,50]), "There are solid blocks in this area, so it is not free."
  end

  def testGetBlockByIndex
    assert_not_nil @map.block_by_indexes(1,1), "The block on indexes 1, 1 must not be nil."
  end


  def testGetAllCollidingBlocks
    ts = Map::TILE_SIZE
    assert_equal 4, @map.blocks_on_square([ts-2, 2*ts-2, ts, ts]).size, "Defined square collides with four tiles."
  end

  def testGetBlockOutOfLocation
    assert_raise(RuntimeError, "Block is out of map, it should not be returned.") {
      @map.blocks_on_square([Map::TILE_SIZE*15, Map::TILE_SIZE * 15, 60, 60])
    }
  end

end # class TestMap
