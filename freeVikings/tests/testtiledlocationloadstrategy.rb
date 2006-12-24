# testtiledlocationloadstrategy.rb
# igneus 15.12.2005

require 'test/unit'

require 'tiledmaploadstrategy.rb'

class TestTiledMapLoadStrategy < Test::Unit::TestCase
  TESTMAP = "data/fourtilesmap.tmx"

  def setup
    @strategy = FreeVikings::TiledMapLoadStrategy.new(File.open(TESTMAP).read)
    @strategy.instance_eval {@dir = "./data"}
    @map = Map.new(@strategy)
  end

  def testRightNumberOfRows
    assert_equal Map::TILE_SIZE*2, @map.rect.w, "Map is two tiles wide."
    assert_equal Map::TILE_SIZE*2, @map.rect.h, "Map is two tiles high."
  end
end
