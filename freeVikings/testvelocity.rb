# testvelocity.rb
# igneus 16.2.2005

# Testy pro tridu Velocity.

require 'rubyunit'

require 'velocity.rb'

class TestVelocity < RUNIT::TestCase

  def setup
    @nulvelocity = Velocity.new
  end

  attach_setup :setup

  def testNulVelocityHasNulValue
    assert_equal 0, @nulvelocity.value, "Velocity object with initial velocity 0 and acceleration 0 must have value 0."
  end

  def testPositiveVelocityDoesNotChange
    vPOSaNUL = Velocity.new(5,0)
    assert_equal 5, vPOSaNUL.value, "Velocity which is not accelerated must not change."
  end

  def testNegativeVelocityDoesNotChange
    vNEGaNUL = Velocity.new(-5,0)
    assert_equal -5, vNEGaNUL.value, "Velocity which is not accelerated must not change."
  end

  def testPositiveVelocityPositivelyAcceleratedGrows
    v = Velocity.new(5, 60)
    assert( (v.value > 5), "Velocity 5 accelerated by 60 should grow.")
  end

  def testPositiveVelocityNegativelyAcceleratedFalls
    v = Velocity.new(5, -60)
    assert( (v.value < 5), "Velocity 5 accelerated by -60 should fall.")
  end

  def testNegativeVelocityNegativelyAcceleratedFalls
    v = Velocity.new(-5, -60)
    assert( (v.value < -5), "Velocity -5 accelerated by -60 should fall.")
  end
end
