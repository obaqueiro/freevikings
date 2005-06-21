# testinventory.rb
# igneus 21.6.2005

# Tests for vikings' inventory.

require 'test/unit'

require 'inventory.rb'

class TestInventory < Test::Unit::TestCase

  def setup
    @inventory = FreeVikings::Inventory.new
  end

  def testEmpty
    assert @inventory.empty?, "Inventory is empty."
  end

  def testFull
    4.times {@inventory.put Object.new}
    assert @inventory.full?, "4 objects have been put into the inventory, it's full."
  end

  def testPut
    @inventory.put(o = Object.new)
    assert_equal o, @inventory.first, "One object has been put into the inventory, it must be in the first slot."
  end

  def testPointerPointsAtTheFirstItemOnTheBeginning
    @inventory.put Object.new
    assert_equal @inventory.first, @inventory.active, "On the beginning the pointer must point at the first item in the inventory."
  end

  def testMovePointer
    4.times {@inventory.put Object.new}
    @inventory.active_index += 1
    assert_equal @inventory.second, @inventory.active, "The pointer was moved, it should now point at the second item."
  end

  def testInvalidPointerMove
    assert_raise(FreeVikings::Inventory::IndexOutOfBoundsException) do
      @inventory.active_index += 5
    end
  end

  def testEraseActive
    @inventory.put(f = Object.new)
    @inventory.put(s = Object.new)
    @inventory.erase_active
    assert_equal s, @inventory.active, "The first item was active. It was erased, now the second one should be active."
  end

  def testGetNullItem
    assert_kind_of FreeVikings::NullItem, @inventory.fourth, "The inventory is empry, so it should return a NullItem object."
  end
end
