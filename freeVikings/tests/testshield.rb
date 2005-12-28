# testshield.rb
# igneus 12.6.2005

# Unit tests for class Shield.

require 'test/unit'
require 'schwerengine/schwerengine.rb'

require 'mockclasses.rb'

require 'shield.rb'
require 'monsters/redshot.rb'
require 'monsters/robot.rb'
require 'arrow.rb'

class TestShield < Test::Unit::TestCase

  include FreeVikings::Mock

  LEFT = 0; TOP = 0; WIDTH = 0; HEIGHT = 0;

  # Objekt TestShield je pri inicializaci predavan objektu
  # Shield jako falesny stitonos a musi tedy podporovat prislusne rozhrani.
  # Musime includovat Mixin Hero, aby stit zastavoval vsechny strely,
  # ktere zabijeji hrdiny. Tim imitujeme chovani, jake ma stit
  # v drzeni vikinga Olafa.
  # Methoda rect vraci pozici imaginarniho stitonose, methoda shield_use
  # zase zpusob, jakym je stit drzen.

  include Hero

  def rect
    Rectangle.new LEFT, TOP, WIDTH, HEIGHT
  end

  def shield_use
    'right' # nemenit, testy tuto hodnotu predpokladaji
  end

  def alive?
    true
  end

  # Nasleduji vlastni testy.

  def setup
    @location = MockLocation.new
    @shield = Shield.new self
    @location.add_sprite @shield
  end

  def testShieldStopsPlasmaShot
    shot = RedShot.new [0,0], 0
    @location.sprites_on_rect = [shot, @shield]
    @shield.unofficial_update
    assert_equal false, shot.alive?, "Shield should have killed the colliding RedShot."
  end

  def testShieldDoesNotStopAnArrow
    arrow = Arrow.new [0,0], 0
    @location.sprites_on_rect = [arrow, @shield]
    @shield.unofficial_update
    assert_equal true, arrow.alive?, "Shield shouldn't have killed an arrow, because Baleog must be able to shoot through Olaf's shield."
  end

  def testOriginalSetup
    assert_equal 'right', shield_use, "When these tests were being written, I presumed the shield is holded on the right side of the shielder. If the setup was changed, tests can't work well. This test just controls the setup."
  end
end
