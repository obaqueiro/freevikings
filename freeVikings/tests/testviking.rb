# testviking.rb
# igneus 21.2.2005

require 'testsprite.rb'

require 'viking.rb'

require 'mockclasses'

class TestViking < TestSprite

  include Mock

  def setup
    @sprite = Viking.new('Wulftan', STARTPOS) # a viking for TestSprite tests
    @viking = Viking.new('Donnas', [0,0])
    @location = MockLocation.new
    @viking.location = @location
  end

  def testDoesNotStartFallingWhenOnGround
    @location.position_validator_proc = Proc.new do |sprite, position|
      return false if position[1] != 0
    end
    @viking.update
    assert_equal false, @viking.falling?, 'Viking should not be falling, he should think he is on ground (actually MockLocation does not provide any ground).'
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
end
