# testwall.rb
# igneus 12.11.2008

require 'wall.rb'

class TestWall < Test::Unit::TestCase

  def setup
    @wall = FreeVikings::Wall.new [0,0], 2, 5, self
  end

  def testNumBricks
    assert_equal 10, @wall.num_bricks
  end

  def testBrickCoordinatesFirstBrick
    assert_equal [0,0], @wall.brick_coordinates(0)
  end

  def testBrickCoordinatesSecondBrick
    assert_equal [40,0], @wall.brick_coordinates(1)
  end

  def testBrickCoordinatesThirdBrick
    assert_equal [0,40], @wall.brick_coordinates(2)
  end

  def testBrickCoordinatesSixthBrick
    assert_equal [40,80], @wall.brick_coordinates(5)
  end
end
