# testvikingstate.rb
# igneus 11.3.2005

# Sada testovych pripadu pro stavove prechody vikingu.
# (Potrebuji provest par optimalizacnich uprav a chci mit jistotu, ze nenadelam
# neporadek.)

require 'rubyunit'

require 'viking.rb'
require 'vikingstate.rb'

class TestVikingState < RUNIT::TestCase

  include FreeVikings

  VikingState = Future::VikingState

  def setup
    @state = VikingState.new
  end

  def testLeftDirectionAfterMoveLeft
    @state.move_left
    assert_equal "left", @state.direction, "The direction must be left after move_left call."
  end

  def testRightDirectionAfterMoveRight
    @state.move_right
    assert_equal "right", @state.direction, "The direction must be right after move_right call."
  end

  def testInitialDirectionIsRight
    assert_equal 'right', @state.direction, "I want the initial direction to be 'right'."
  end

  def testRightVelocityIsPositive
    @state.move_right
    assert @state.velocity_horiz > 0, "The sprite will be moving right. It's horizontal velocity must be positive."
  end

  def testLeftVelocityIsNegative
    @state.move_left
    assert @state.velocity_horiz < 0, "The sprite will be moving left. It's horizontal velocity must be negative."
  end

  def testHorizontalStateChangesDontMakeChaos
    @state.move_left
    @state.move_right
    assert_equal 'right', @state.direction, "The horizontal state has been changed twice, but it should still be consistent."
  end

  def testZeroHorizontalVelocityWhenStanding
    @state.stop
    assert_equal 0, @state.velocity_horiz, "Standing sprite must have zero velocity."
  end

  def testZeroVerticalVelocityWhenStanding
    @state.stop
    assert_equal 0, @state.velocity_vertic, "Standing sprite must have zero velocity."
  end

  def testPositiveVerticalVelocityWhenFalling
    @state.fall
    assert @state.velocity_vertic > 0, "Falling sprite must have a positive vertical velocity."
  end

end
