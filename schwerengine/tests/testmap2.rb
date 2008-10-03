# testmap2.rb
# igneus 3.10.2008

# test cases from TestMap are inherited!

class TestMap2 < TestMap

  def setup
    @map = Map2.new(Mock::TestingMap2LoadStrategy.new)
  end

  # this needs to be redefined

  def testRect
    r = self.class::RECT.new(0, 0, Map::TILE_SIZE * 8, Map::TILE_SIZE * 8)
    assert_equal r, self.class::RECT.new(0, 0, @map.width, @map.height), "The two rectangles should contain the same numbers => eql? is expected to be true."
  end
end
