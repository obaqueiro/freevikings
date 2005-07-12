# testviking.rb
# igneus 21.2.2005

require 'testsprite.rb'

require 'viking.rb'

require 'mockclasses'

class TestViking < TestSprite

  include Mock

  def setup
    @entity = @sprite = Viking.new('Wulftan', STARTPOS) # a viking for TestSprite tests
    @viking = Viking.new('Donnas', [0,0])
    @location = MockLocation.new
    @viking.location = @location
  end

  def testDoesNotStartFallingWhenOnGround
    @location.position_validator_proc = Proc.new do |sprite, position|
      return false if position[1] != 0
    end
    @viking.update
    assert_equal false, @viking.state.falling?, 'Viking should not be falling, he should think he is on ground (actually MockLocation does not provide any ground).'
  end

  def testDoesNotStopDuringAWalk
    @viking.move_right
    2.times {@viking.update}
    assert_equal false, @viking.standing?, "Viking must not stop when he has no collisions with map blocks and we haven't told him to."
  end

  def testHasLeftMethod
    assert_respond_to @viking, :left
  end

  def testMethodLeftWorks
    assert_equal 0, @viking.left
  end

  def testAddedToTheLocation
    v = Viking.new('Raymund BlueTooth', STARTPOS)
    loc = MockLocation.new
    loc.add_sprite v
    assert_equal loc, v.location, "MockLocation should have set viking's 'location' attribute."
  end

  def testCannotMoveHorizontallyButCanVertically
    @location.add_sprite @viking
    # During the update, viking calls is_position_valid? several times:
    answers_array = [
      false, # question: Can I move horizontally and vertically? (update)
      true, # question: Can I move vertically? (update)
      true # question: Can I fall deeper? (on_ground?)
    ]
    @location.position_validator_proc = Proc.new { answers_array.shift }
    @viking.state.fall
    @viking.move_left
    @viking.update
    assert_equal 'falling_moving_left', @viking.state.to_s, "Viking can't move horizontally. He won't change his y-axis position, but his state should stay 'left moving', because he must continue moving as soon as he is able to."
  end

  def testHurtReturnValueIsInteger
    assert_equal 2, @viking.hurt, "Viking#hurt should return number of energy points after the injury."
  end

  def testDestroyReturnsSelf
    assert_equal @viking, @viking.destroy, "Viking#destroy should return the Viking itself."
  end
end
