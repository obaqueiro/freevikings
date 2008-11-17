# testrect.rb
# igneus 22.2.2005

# Testy pro tridu Rect, ktera by mela obalit operace nad
# obdelniky.

require 'test/unit'

require 'rect.rb'

class TestRect < Test::Unit::TestCase

  include SchwerEngine

  def setup
    @R = Rectangle
    @r1 = @R.new 60,60,60,60
  end

  def testNearlyContains
    r1 = @R.new(60,0,60,60)
    r2 = @R.new(50,20,60,10)
    assert r2.collides?(r1), "r2 collides with r1. It's a similar situation as a typical collision of the sword and a creature."
  end

  def testNorthWestCornerCollision
    r2 = @R.new 50,50,60,60
    assert @r1.collides?(r2), "r1 collides with r2 on it's northwest corner"
  end

  def testSouthWestCornerCollision
    r2 = @R.new 50,70,60,60
    assert @r1.collides?(r2), "r1 collides with r2 on it's southwest corner"
  end

  def testNorthEastCornerCollision
    r2 = @R.new 70,50,60,60
    assert @r1.collides?(r2), "r1 collides r2 on it's northeast corner"
  end

  def testContainsCollision
    r1 = @R.new(0,0,60,60)
    r2 = @R.new(10,10,2,2)
    assert r1.collides?(r2), "r1 contains r2, so it collides with it."
  end

  def testContainedCollision
    r1 = @R.new(0,0,60,60)
    r2 = @R.new(10,10,2,2)
    assert r2.collides?(r1), "r2 contains r1, so r1 collides with r2"
  end

  def testIndexingLeft
    r = @R.new 1, 2, 3, 4
    assert_equal 1, r.left
    assert_equal 1, r[0]
  end

  def testInitializationByRectangle
    r = @R.new 1, 1, 2, 3
    s = @R.new r
    assert_equal r.left, s.left, "s was initialized by values from r, so their 'left' values should be the same."
  end

  def testExpandX
    r = @R.new 5, 5, 5, 5
    s = r.expand(1)
    assert_equal @R.new(4, 5, 7, 5), s, "'Expand 1px in x axis' means 'left-=1, right+=1'"
  end

  def testExpand!
    r = @R.new 5, 5, 5, 5
    r.expand!(1,1)
    assert_equal @R.new(4,4,7,7), r
  end

  def testArea
    r = @R.new 0,0,2,2
    assert_equal 4, r.area, "Area of a square of size 2 is 4."
  end

  def testCommonEmpty
    r1 = @R.new 0,0,2,2
    r2 = @R.new 10,10,10,10
    assert r1.common(r2).empty?, "Common area of these two rectangles is empty - empty rectangle wanted!"    
  end

  def testCommon
    r1 = @R.new 0,0,10,10
    r2 = @R.new 0,0,5,5
    assert_equal r2, r1.common(r2)
  end

  def testCommon2
    r1 = @R.new 0,10,100,10
    r2 = @R.new 10,0,10,100
    assert_equal @R.new(10,10,10,10), r1.common(r2)
  end

  def testBottomAssign
    r1 = @R.new 0,0,5,5
    r1.bottom = 50
    assert_equal 50, r1.h
  end

  def testRightAssign
    r1 = @R.new 0,0,5,5
    r1.right = 50
    assert_equal 50, r1.w
  end

  def testNewFromPoints_topleft_bottomright
    r = @R.new_from_points([10,10], [20,20])
    assert_equal @R.new(10,10,10,10), r
  end

  def testNewFromPoints_topright_bottomleft
    r = @R.new_from_points([20,10], [10,20])
    assert_equal @R.new(10,10,10,10), r
  end

  def testNewFromPoints3
    r = @R.new_from_points([10,10], [60,20])
    assert_equal @R.new(10,10,50,10), r
  end

  def testCenter1
    r = @R.new 0,0,4,4
    assert_equal [2,2], r.center
  end

  def testCenter2
    r = @R.new 0,0,5,5
    assert_equal [2,2], r.center
  end

  def testMove!
    r = @R.new 100,100,100,100
    r.move!(10,-10)
    assert_equal 110, r.left
    assert_equal 90, r.top
  end
end
