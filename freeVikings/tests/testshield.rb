# testshield.rb
# igneus 12.6.2005

# Unit tests for class Shield.

require 'test/unit'
require 'schwerengine/schwerengine.rb'

require 'mockclasses.rb'

require 'shield.rb'
require 'redshot.rb'
require 'robot.rb'
require 'arrow.rb'

class TestShield < Test::Unit::TestCase

  include FreeVikings::Mock

  LEFT = 0; TOP = 0; WIDTH = 0; HEIGHT = 0;

  # TestShield has interface of a Shielder, because it pretends to be 
  # a Shielder while testing a Shield

  include Hero

  def rect
    Rectangle.new LEFT, TOP, WIDTH, HEIGHT
  end

  alias_method :paint_rect, :rect
  alias_method :collision_rect, :rect

  def shield_use
    'right' # don't change, tests want it so
  end

  def alive?
    true
  end

  def z
    7
  end

  def setup
    @location = MockLocation.new
    @shield = Shield.new self
    @location << @shield
  end

  def testShieldStopsPlasmaShot
    shot = RedShot.new [0,0], 0
    shot.location = @location
    @location.sprites_on_rect = [shot, @shield]
    @shield.unofficial_update @location
    assert_equal false, shot.alive?, "Shield should have killed the colliding RedShot."
  end

  def testShieldDoesNotStopAnArrow
    arrow = Arrow.new [0,0], 0
    @location.sprites_on_rect = [arrow, @shield]
    @shield.unofficial_update @location
    assert_equal true, arrow.alive?, "Shield shouldn't have killed an arrow, because Baleog must be able to shoot through Olaf's shield."
  end

  def testOriginalSetup
    assert_equal 'right', shield_use, "When these tests were being written, I presumed the shield is holded on the right side of the shielder. If the setup was changed, tests can't work well. This test just controls the setup."
  end
end
