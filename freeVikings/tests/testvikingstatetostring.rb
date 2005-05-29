# testvikingstatetostring.rb
# igneus 26.5.2005

# Sada testovych pripadu kontrolujicich, zda metoda VikingState#to_s
# vraci spravne sestavene textove retezce symbolicky popisujici
# obrazek, ktery ma byt pouzit pro zobrazeni vikinga v danem stavu.

require 'test/unit'

require 'vikingstate.rb'
require 'ability.rb'

class TestVikingStateToString < Test::Unit::TestCase

  include FreeVikings

  def setup
    @state = VikingState.new
  end

  def testStandingOnGround
    @state.stop
    @state.descend
    assert_equal "onground_standing_right", @state.to_s
  end

  def testWalkingLeftFalling
    @state.move_left
    @state.fall
    assert_equal 'falling_moving_left', @state.to_s
  end

  def testWalkingRight
    @state.move_right
    @state.descend
    assert_equal "onground_moving_right", @state.to_s
  end

  def testAbilityActive
    @state.ability = MockAbility.new
    assert_equal "onground_mocking_right", @state.to_s
  end
end


class MockAbility < FreeVikings::Ability
  def to_s
    'mocking'
  end
end
