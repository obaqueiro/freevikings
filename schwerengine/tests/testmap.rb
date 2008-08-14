# testmap.rb
# igneus 13.2.2005

# Sada testovych pripadu pro tridu Map

require 'test/unit'

class TestMap < Test::Unit::TestCase

  include SchwerEngine

  RECT = Rectangle

  def setup
    @map = Map.new(Mock::TestingMapLoadStrategy.new)
  end

  def testRect
    r = self.class::RECT.new(0, 0, Map::TILE_SIZE * 8, Map::TILE_SIZE * 8)
    assert(r.eql?(@map.rect), "The two rectangles (#{r.to_s} and #{@map.rect.to_s}) should contain the same numbers => eql? is expected to be true.")
  end

  def testNonFreeArea
    assert_equal(false,
                 @map.area_free?(self.class::RECT.new(5,5,40,40)),
                 "Area isn't free, it collides with solid tiles.")
  end

  def testCentralAreaFree
    assert_equal(true, 
                 @map.area_free?(self.class::RECT.new(50,50,10,10)),
                 "Area is free.")
  end

  def testFreeOnTheEdgeOfFreeArea1
    assert_equal(true, @map.area_free?(RECT.new(40,40,5,5)),
                 "Area is free, but it is on the topleft edge of solid tiles.")
  end

  def testFreeOnTheEdgeOfFreeArea2
    assert_equal(true, @map.area_free?(RECT.new(60,240,40,40)),
                 "Area is free, but it is on the top edge of solid tiles.")
  end

end # class TestMap
