# testextmap.rb
# igneus 6.11.2005

# Test cases for class FreeVikings::Extensions::Map.
# It is a C++ (=> quicker) reimplementation of the standard FreeVikings::Map.

require 'test/unit'

require 'tile.rb'

class TestExtensionMap < Test::Unit::TestCase

  include FreeVikings

  begin
    MAP = FreeVikings::Extensions::Map
  rescue NameError => e
    puts e.message
  end

  def setup
    @map = MAP.new
  end

  def testClassExists
    assert_kind_of Class, FreeVikings::Extensions::Map, "The tested class must exist at first."
  end

  def testInsertTile
    assert_nothing_raised("It should be possible to add a Tile.") do
      @map.new_tiles_line
      @map.add_tile Tile.new()
    end
  end

  def testUpdatedMapWidthAfterTilesAdded
    @map.new_tiles_line
    7.times {@map.add_tile Tile.new}
    assert_equal 7, @map.tiles_columns, "Seven tiles have been added."
  end

  def testUpdatedMapHeightAfterTilesAdded
    3.times {
      @map.new_tiles_line
      @map.add_tile Tile.new
    }
    assert_equal 3, @map.tiles_rows, "Three rows of tiles have been made."
  end

  def testExceptionIfSecondLineLongerThanFirst
    @map.new_tiles_line
    3.times { @map.add_tile Tile.new}

    @map.new_tiles_line
    assert_raise(RuntimeError, "All the rows must be of same length. Here they aren't, so we expect an exception.") do
      7.times { @map.add_tile Tile.new}
    end
  end

  def testExceptionWhenAddingToMapWithNoRow
    assert_raise(RuntimeError, "'new_tiles_line' hasn't been called so no map row has been initialized. An exception must be raised.") do
      @map << Tile.new
    end
  end

  def testHasAddedTile
    @map.new_tiles_line
    @map.add_tile(inserted = Tile.new)
    assert_equal(inserted, @map.get_at(0,0), "The inserted tile should be returned.")
  end

  def testTileOutOfMapIsNil
    @map.new_tiles_line
    @map.add_tile(inserted = Tile.new)
    assert_equal(nil, @map.get_at(100,200), "Tile 100,200 doesn't exist, nil is expected.")
  end

  # prepares a bigger map (used for testing Map#area_free?)
  def setupAreaFreeTests
    x = @solid_tile = Tile.new('', true)
    o = @soft_tile = Tile.new('', false)

    [[x, x, x, x],
     [x, o, o, x],
     [x, o, o, x],
     [x, x, x, x]].each do |row|
      @map.new_tiles_line
      row.each do |tile|
        @map.add_tile tile
      end
    end
  end

  def testCentralAreaFree
    setupAreaFreeTests

    assert_equal(true, 
                 @map.area_free?(Rectangle.new(50,50,10,10)),
                 "Area is free.")
  end

  def testNonFreeArea
    setupAreaFreeTests

    assert_equal(false,
                 @map.area_free?(Rectangle.new(5,5,40,40)),
                 "Area isn't free, it collides with three solid tiles.")
  end

  def testRect
    setupAreaFreeTests

    assert_equal(4*40, @map.rect.w, "Map width is 160.")
    assert_equal(4*40, @map.rect.h, "Map height is 160.")
  end
end
