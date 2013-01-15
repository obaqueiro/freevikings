# testmap.rb
# igneus 13.2.2005

# Sada testovych pripadu pro tridu Map

require 'test/unit'

class TestMap < Test::Unit::TestCase

  include SchwerEngine

  RECT = Rectangle
  TILE_SIZE = 40

  def setup
    strat = Mock::TestingMapLoadStrategy.new do |x,o|
      [
       [x, x, x, x, x, x, x, x],
       [x, o, o, o, o, o, x, x],
       [x, o, o, o, o, o, x, x],
       [x, o, o, o, o, o, x, x],
       [x, o, o, o, o, o, x, x],
       [x, o, o, o, o, o, x, x],
       [x, o, o, o, o, o, x, x],
       [x, x, x, x, x, x, x, x]         
      ]
    end
    @map = Map.new(strat)
  end

  def testRect
    r = self.class::RECT.new(0, 0, TILE_SIZE * 8, TILE_SIZE * 8)
    assert_equal r, @map.rect, "The two rectangles (#{r.to_s} and #{@map.rect.to_s}) should contain the same numbers => eql? is expected to be true."
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

  def testFreeOnTheEdgeOfFreeAreaBottomCollision
    assert_equal(true, @map.area_free?(RECT.new(100,240,40,39)))
  end

  def testNonFreeOnTheEdgeOfFreeAreaBottomCollision
    assert_equal(false, @map.area_free?(RECT.new(100,240,40,41)))
  end

  def testFreeOnTheEdgeOfFreeAreaRightCollision
    assert_equal(true, @map.area_free?(RECT.new(200,60,39,40)))
  end

  def testNonFreeOnTheEdgeOfFreeAreaRightCollision
    assert_equal(false, @map.area_free?(RECT.new(200,60,40,40)))
  end

  def testLargestFreeRect_OK
    center = [80,80]
    assert_equal RECT.new(40,40,200,240), @map.largest_free_rect(center)
  end

  def testLargestFreeRect_error
    center = [0,0]
    assert_equal RECT.new(0,0,0,0), @map.largest_free_rect(center), "[0,0] is not in a free area - returned rect must be empty"
  end

  def testPointFree
    assert_equal true, @map.point_free?([50,50]), "Point in free area"
    assert_equal false, @map.point_free?([10,10]), "Point in solid tile"

    assert_equal false, @map.point_free?([-50, -50]), "Point out of map"
    assert_equal false, @map.point_free?([70000, 80000]), "Point out of map"
  end

  def testFindSurfaceNoSurface
    assert_equal nil, @map.find_surface(RECT.new(60,60,60,60)), "No surface in rectangle"
  end

  def testFindSurface
    assert_equal RECT.new(@map.tile_width, 7*@map.tile_height, 5*@map.tile_width, 0), @map.find_surface(RECT.new(60,60,60,1000))
  end
end # class TestMap
