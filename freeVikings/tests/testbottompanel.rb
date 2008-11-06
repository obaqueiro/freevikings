# testbottompanel.rb
# igneus 25.7.2005

# Test cases for the BottomPanel class.

require 'test/unit'

require 'bottompanel.rb'

class TestBottomPanel < Test::Unit::TestCase

  include FreeVikings

  def setup
    @johann = Viking.new 'Johann'
    @greg = Viking.new 'Greg'
    @beda = Viking.new 'Beda'
    @team = Team.new @johann, @greg, @beda
    @bottompanel = BottomPanel.new @team
  end

  def testClickSwitchActiveViking
    spot_in_gregs_portrait = [BottomPanel::VIKING_FACE_SIZE + BottomPanel::INVENTORY_VIEW_SIZE + 5, 5]
    @bottompanel.mouseclick(spot_in_gregs_portrait)
    assert_equal @greg, @team.active, "Greg must be active now, because we have simulated a mouse click on his portrait."
  end

  def testClickSwitchActiveItem
    # Fill Johann's inventory:
    @johann.inventory.put "knife"
    @johann.inventory.put "spoon"

    assert_equal "spoon", @johann.inventory.active, "A control assert. 'spoon' must be active, it was put into the inventory later then 'knife'."

    # Click onto the first item in Johann's inventory:
    spot_in_johanns_first_item = [BottomPanel::VIKING_FACE_SIZE + 5, 5]
    @bottompanel.mouseclick(spot_in_johanns_first_item)
    @bottompanel.mouserelease(spot_in_johanns_first_item)

    assert_equal "knife", @johann.inventory.active, "We've simulated click onto a 'knife', so it must be active."
  end
end
