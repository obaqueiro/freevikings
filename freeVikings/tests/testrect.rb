# testrect.rb
# igneus 22.2.2005

# Testy pro tridu Rect, ktera by mela obalit operace nad
# obdelniky.

require 'rubyunit'

require 'rect.rb'

include FreeVikings

class TestRect < RUNIT::TestCase

  def setup
    @r1 = Rectangle.new 60,60,60,60
  end

  def testContains
    r1 = Rectangle.new(0,0,60,60)
    r2 = Rectangle.new(10,10,2,2)
    assert r1.contains?(r2), "r1 contains r2."
  end

  def testDoesNotContain
    r1 = Rectangle.new(0,0,60,60)
    r2 = Rectangle.new(10,10,2,2)
    assert_nil r2.contains?(r1), "r2 does not contain r1."
  end

  def testNearlyContains
    r1 = Rectangle.new(60,0,60,60)
    r2 = Rectangle.new(50,20,60,10)
    assert r2.collides?(r1), "r2 collides with r1. It's a similar situation as a typical collision of the sword and a creature."
  end

  def testNorthWestCornerCollision
    r2 = Rectangle.new 50,50,60,60
    assert @r1.collides?(r2), "r1 collides with r2 on it's northwest corner"
  end

  def testSouthWestCornerCollision
    r2 = Rectangle.new 50,70,60,60
    assert @r1.collides?(r2), "r1 collides with r2 on it's southwest corner"
  end

  def testNorthEastCornerCollision
    r2 = Rectangle.new 70,50,60,60
    assert @r1.collides?(r2), "r1 collides r2 on it's northeast corner"
  end

  def testContainsCollision
    r1 = Rectangle.new(0,0,60,60)
    r2 = Rectangle.new(10,10,2,2)
    assert r1.collides?(r2), "r1 contains r2, so it collides with it."
  end

  def testContainedCollision
    r1 = Rectangle.new(0,0,60,60)
    r2 = Rectangle.new(10,10,2,2)
    assert r2.collides?(r1), "r2 contains r1, so r1 collides with r2"
  end
end
