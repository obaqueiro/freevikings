# testmap.rb
# igneus 13.2.2005

# Sada testovych pripadu pro tridu Map

require 'test/unit'

require 'map.rb'
require 'locationloadstrategy.rb'
require 'tiletype.rb'
require 'mockclasses.rb'

class TestMap < Test::Unit::TestCase

  include FreeVikings

  def rect
    Rectangle.new 90, 90, 60, 60
  end

  def solid?
    true
  end

  def setup
    @map = Map.new(Mock::TestingMapLoadStrategy.new)
  end

  def testGetSolidBlock
    assert @map.blocks_on_square([0,0,50,50])[0].solid, "The first block in tho top left corner is solid. I made it solid."
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

  def testRect
    r = Rectangle.new(0, 0, Map::TILE_SIZE * 8, Map::TILE_SIZE * 8)
    assert(r.eql?(@map.rect), "The two rectangles (#{r.to_s} and #{@map.rect.to_s}) should contain the same numbers => eql? is expected to be true.")
  end

  def testStaticObject
    @map.static_objects.add self
    assert_equal self, @map.static_objects.members_on_rect(Rectangle.new(80,80,10,10))[0], "A TestMap instance was added into a Map as a solid static object."
  end

end # class TestMap

class FreeVikings::Rectangle
  def to_s
    "[#{left}, #{top}, #{w}, #{h}]"
  end
end
