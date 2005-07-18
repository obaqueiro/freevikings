# testbottompanelstate.rb
# igneus 24.7.2005

# Tests for class BottomPanelState and it's three subclasses.
# They have their own small TestSuite.

require 'test/unit'

require 'bottompanelstate.rb'
require 'viking.rb'

class TestBottomPanelState < Test::Unit::TestSuite

  def TestBottomPanelState.suite
    suite = Test::Unit::TestSuite.new

    suite << TestItemsExchangeBottomPanelState.suite

    return suite
  end
end


###===### TestItemsExchangeBottomPanelState ###=============================###

class TestItemsExchangeBottomPanelState < Test::Unit::TestCase

  include FreeVikings

  def setup
    @viking1 = Viking.new 'Vili'
    @viking2 = Viking.new 'Vali'
    @viking3 = Viking.new 'Ve'
    @team = Team.new @viking1, @viking2, @viking3

    @state = ItemsExchangeBottomPanelState.new @team
  end

  def testGiveItemToSomeoneWhoseInventoryIsFull
    4.times {@viking2.inventory.put "knife"} # Vali's inventory is full now
    @viking1.inventory.put "fork"
    assert_equal(@viking1, @team.active)
    # Vili gives his fork to Vali. Vali's inventory is full, so the fork must
    # be given to Ve.
    @state.right
    assert_equal "fork", @viking3.inventory.active, "The item must have been given to the third viking, because the second one has no inventory slot free."
  end
end
