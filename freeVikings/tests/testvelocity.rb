# testvelocity.rb
# igneus 16.2.2005

# Testy pro tridu Velocity.

require 'rubyunit'

require 'velocity.rb'

class TestVelocity < RUNIT::TestCase

  def setup
    @nulvelocity = Velocity.new
  end

  def testNulVelocityHasNulValue
    assert_equal 0, @nulvelocity.value, "Velocity object with initial velocity 0 and acceleration 0 must have value 0."
  end

  def testPositiveVelocityDoesNotChange
    vPOSaNUL = Velocity.new 5
    assert_equal 5, vPOSaNUL.value, "Velocity which is not accelerated must not change."
  end

  def testNegativeVelocityDoesNotChange
    vNEGaNUL = Velocity.new -5
    assert_equal -5, vNEGaNUL.value, "Velocity which is not accelerated must not change."
  end

end
