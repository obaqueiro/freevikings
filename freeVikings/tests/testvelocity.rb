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

  def testPositiveVelocityNegativelyAcceleratedDecreases
    v = Velocity.new(5, -60)
    assert( (v.value < 5), "Velocity 5 accelerated by -60 should decrease.")
  end

  def testNegativeVelocityNegativelyAcceleratedDecreases
    v = Velocity.new(-5, -60)
    assert( (v.value < -5), "Velocity -5 accelerated by -60 should decrease.")
  end

  def testNegativeVelocityPositivelyAcceleratedIncreases
    v = Velocity.new(-5, 60)
    assert( (v.value > -5), "Velocity -5 accelerated by 60 should grow.")
  end

  def testNegativeVelocityDoesNotIncreaseOverZero
    v = Velocity.new(-1, 1000)
    assert_equal 0, v.value, "Negative velocity positively accelerated should stop it's accelerating on zero."
  end

  def testPositiveVelocityDoesNotDecreaseUnderZero
    v = Velocity.new(1, -1000)
    assert_equal 0, v.value, "Positive velocity negatively accelerated should stop it's decreasing on zero."
  end

  def testPositiveAccelerationWorksWell
    v = Velocity.new(1, 2)
    assert_equal 3, v.value(1), "Velocity with initial value 1 and acceleration 2 should be 3 after 1 second."
  end

  def testNegativeAccelerationWorksWell
    v = Velocity.new(5, -2)
    assert_equal 3, v.value(1), "Velocity with initial value 5 and acceleration -2 should after one second have value 3."
  end
end
