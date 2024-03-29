# testsophisticatedspritestate.rb
# igneus 28.6.2005

# Test cases for LeggedSpriteState.

require 'test/unit'

class TestSophisticatedSpriteState < Test::Unit::TestCase

  include FreeVikings

  def setup
    @state = SophisticatedSpriteState.new
  end

  def testLeftDirectionAfterMoveLeft
    @state.move_left
    assert_equal "left", @state.direction, "The direction must be left after move_left call."
  end

  def testRightDirectionAfterMoveRight
    @state.move_right
    assert_equal "right", @state.direction, "The direction must be right after move_right call."
    assert @state.right?
  end

  def testMoveBackChangesDirection
    @state.move_right
    @state.move_back
    assert_equal 'left', @state.direction, "Call to 'move_back' must change the direction."
  end

  def testMoveBackStartsMovement
    @state.move_back
    assert @state.moving?, "The sprite is moving back, so it is moving."
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

  def testNotMovingWhenStanding
    assert_equal false, @state.moving?, "Sprite does not fall or rise or walk, it is not moving."
  end

  def testPositiveVerticalVelocityWhenFalling
    @state.fall
    assert @state.velocity_vertic > 0, "Falling sprite must have a positive vertical velocity."
  end

  def testFalling?
    @state.fall
    assert @state.falling?, "'falling?' should return true, 'fall' was called just a millisecond ago."
  end

  def testMovingWhenFalling
    @state.fall
    assert_equal true, @state.moving?, "Falling sprite is moving."
  end

  def testDescendStopsTheFall
    @state.fall
    @state.descend
    assert_equal 0, @state.velocity_vertic, "The falling sprite descended, it should not carry on falling."
  end

  def testStopWorks
    @state.move_right
    @state.stop
    assert_equal 0, @state.velocity_horiz, "I was really terrified \ 
when I found out that the important method VikingState#stop has \
empty definition. More similar mistakes and we are somewhere in the hell..."
  end

  def testNegativeVerticalVelocityWhenRising
    @state.rise
assert @state.velocity_vertic < 0, "The velocity must be less then zero when the sprite is rising."
  end

  def testMovingHorizontally
    @state.move_left
    assert @state.moving_horizontally?, "Method 'moving_horizontally?' must return true when moving left."
  end

  def testMovingVertically
    @state.fall
    assert @state.moving_vertically?, "Method 'moving_vertically?' must return true when falling."
  end

  def testKnockedOutNotMoving
    @state.move_left
    @state.knockout
    assert_equal false, @state.moving?, "Sprite is knocked out, it isn't moving."
  end

  def testCannotMoveWhenKnockedOut
    @state.knockout
    @state.move_left
    assert_equal false, @state.moving?, "Knockedout sprite can't move until it is unknockedout."
  end

  def testMovableAgainAfterUnknockout
    @state.knockout
    @state.unknockout
    @state.move_left
    assert @state.moving?, "Knockedout sprite can move again after 'unknockout' method is called."
  end

  def testCannotChangeHorizStateToStandingWhenKnockedOut
    @state.knockout
    @state.stop
    assert(!(@state.to_s =~ /standing/), "When the sprite is knocked out, it mustn't be able to change to the Standing state directly")
  end

end
