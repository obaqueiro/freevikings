# testmonster.rb
# igneus 16.7.2005

require 'test/unit'

require 'monster.rb'
require 'monstermixins.rb'
require 'shield.rb'
require 'shielder.rb'
require 'location.rb'
require 'mockclasses.rb'

class TestMonster < Test::Unit::TestCase

  include FreeVikings::Monster
  include FreeVikings::MonsterMixins::ShieldSensitive

  include FreeVikings
  include FreeVikings::Mock

  def alive?
    true
  end

  MONSTER_RECT = Rectangle.new(0, 0, 60, 60) # any rect except of ?,?,0,0
  SHIELDER_POS = [0, 0] # any inside the MONSTER_RECT

  def rect
    MONSTER_RECT
  end

  def setup
    @location = Location.new(TestingMapLoadStrategy.new)

    shielder = Shielder.new("", SHIELDER_POS)
    shield = Shield.new(shielder)

    @location.add_sprite shielder
    @location.add_sprite shield
  end

  def testStoppedByShield
    assert self.stopped_by_shield?, "Monster collides with the shield, so it is stopped."
  end
end
