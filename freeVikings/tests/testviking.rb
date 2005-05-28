# testviking.rb
# igneus 21.2.2005

require 'rubyunit'

require 'testsprite.rb'

require 'viking.rb'

class TestViking < TestSprite

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
end


# A corrupted class MockLocation.
# A mock location has no internal mechanism, it just stores
# the data we want her to return from method calls.
class MockLocation
  def initialize
    @position_validator_proc = Proc.new {|sprite, position| true}
  end

  def add_sprite(sprite)
  end

  def delete_sprite(sprite)
  end

  attr_accessor :position_validator_proc

  def is_position_valid?(sprite, position)
    return @position_validator_proc.call(sprite, position)
  end
end
