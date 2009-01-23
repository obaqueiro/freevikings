# testsword.rb
# igneus 20.7.2005

# Test cases set for a class Sword.

require 'test/unit'
require 'mockclasses.rb'

require 'sword.rb'


class TestSword < Test::Unit::TestCase

  # The TestSword object plays two roles in the tests:
  # it's the owner of the sword and the scapegoat which is hurted
  # by the sword.

  START_ENERGY = 3

  include FreeVikings
  include FreeVikings::Monster # the sword hurts only Monsters

  def hurt
    @energy -= 1
  end

  def setup
    @energy = START_ENERGY

    # The Sword places itself onto it's owner. Because now the owner
    # is a Monster and it collides with the Sword, the Sword will
    # hurt it's owner. Well, not every weapon is designed for universal use :o)
    @rect = Rectangle.new(0,0,60,60)

    @sword = Sword.new(self)

    (@state = Object.new).instance_eval do
      def direction
        'right'
      end
    end

    @location = Mock::MockLocation.new
    @location.add_sprite self
    @location.add_sprite @sword
  end

  attr_reader :rect
  attr_reader :state
  attr_accessor :location

  def testSwordHurtsOncePerUse
    @location.sprites_on_rect = [self, @sword]

    3.times { @sword.update }
    assert(@rect.collides?(@sword.rect), "!!! This is just a control assertion. If it fails, read the test source, please!")
    assert_equal(START_ENERGY - 1, @energy, "The sword should hurt the colliding monsters only once per use (only once after it is drawn - then it must be hidden and drawn once more).")
  end
end
