# testrelativerect.rb
# igneus 17.11.2008

class TestRelativeRect < Test::Unit::TestCase

  include SchwerEngine

  def testFirstTestRelativeRectangle
    r = Rectangle.new(100,100,10,10)
    relr = RelativeRectangle.new(r, 10, 10, 50, 5)

    assert_equal Rectangle.new(110, 110, 60, 15), relr
  end

  def testRelativeRectWithNegativeDifferences
    r = Rectangle.new(100,100,10,10)
    relr = RelativeRectangle.new(r, -10, 10, -2, -5)

    assert_equal Rectangle.new(90, 110, 8, 5), relr
  end

  def testNewRelativeFromTwoRects
    r1 = Rectangle.new(100,100,10,10)
    r2 = Rectangle.new(150,150,10,20)

    s = RelativeRectangle.new2(r1, r2)

    assert_equal r2, s
  end

  def testEqualRects
    r1 = Rectangle.new(10,10,10,10)
    eqrr = RelativeRectangle.new(r1,0,0,0,0)

    assert_equal r1, eqrr
  end
end
