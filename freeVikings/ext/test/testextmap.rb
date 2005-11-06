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
end
