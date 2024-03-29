# testinventory.rb
# igneus 21.6.2005

# Tests for vikings' inventory.

require 'test/unit'

require 'inventory.rb'

class TestInventory < Test::Unit::TestCase

  def setup
    @inventory = FreeVikings::Inventory.new
  end

  def testInitialActiveIndexIsZero
    assert_equal 0, @inventory.active_index, "When a new Inventory is initialized, it's active slot should be 0, even if it is empty."
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
    @inventory.active_index = 0
    @inventory.active_index += 1
    assert_equal @inventory.second, @inventory.active, "The pointer was moved, it should now point at the second item."
  end

  def testInvalidPointerMove
    assert_raise(FreeVikings::Inventory::IndexOutOfBoundsException) do
      @inventory.active_index += 5
    end
  end

  def testEraseActive
    @inventory.put(f = "flask")
    @inventory.put(s = "swatch-clock")
    @inventory.erase_active
    assert_equal f, @inventory.active, "The second item was active. It was erased, now the first one should be active."
  end

  def testGetNullItem
    assert_kind_of NullItem, @inventory.fourth, "The inventory is empry, so it should return a NullItem object."
  end

  def testPutIntoAFullInventoryRaisesException
    4.times {@inventory.put(Object.new)}
    assert_raise(FreeVikings::Inventory::NoSlotFreeException, "You can't put an Item into a full Inventory. An exception should be thrown.") do
      @inventory.put(Object.new)
    end
  end

  def testCannotMakeAnEmptySlotActive
    assert_raise(FreeVikings::Inventory::EmptySlotRequiredException, "The first slot is empry (no Items have been added yet), so a try to make it active should throw an exception.") do
      @inventory.active_index = 0
    end
  end

  def testNewlyPutIsSetActive
    @inventory.put(s = "sword")
    @inventory.put(f = "flask")
    assert_equal f, @inventory.active, "The item which was put in most recently must be set active."
  end

  def testEraseActiveReturnsErasedItem
    @inventory.put "lantern"
    item = @inventory.active
    assert_equal item, @inventory.erase_active, "Method 'erase_active' must return the erased item."
  end

  def testAtRaisesExceptionIfIndexOutOfBounds
    assert_raise(FreeVikings::Inventory::IndexOutOfBoundsException, "The index is out of bounds, an exception must be thrown.") do
      @inventory.at 999
    end
  end

  def testAtReturnsNullItemIfSlotEmpty
    assert_kind_of NullItem, @inventory.at(1), "Slot index is valid, but the slot is free now. A NullItem instance must be returned."
  end
end
