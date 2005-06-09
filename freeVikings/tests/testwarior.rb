# testwarior.rb
# igneus 9.6.2005

# Testy specialnich vlastnosti vikingu-valecniku.

require 'test/unit'

require 'viking.rb'
require 'mockclasses.rb'

class TestWarior < Test::Unit::TestCase

  include FreeVikings::Mock
  include FreeVikings

  def setup
    @samsson = Viking.createWarior('Samsson', [0,0])
    @loc = MockLocation.new
    @samsson.location = @loc
  end

  def testWalkWhenCutting
    @samsson.space_func_on # tasi mec
    @samsson.move_left
    assert_equal false, @samsson.moving?, "Warior Samsson can't walk, he is cutting now."
  end

  def testWalkWhenShooting
    @samsson.d_func_on # nasadi sip na tetivu
    @samsson.move_left
    assert_equal false, @samsson.moving?, "Warior Samsson can't walk, he is stretching his bow and preparing for a shoot now."
  end

  def testStopWhenCutDuringAWalk
    @samsson.move_left
    @samsson.space_func_on
    assert_equal false, @samsson.moving?, "Warior Samsson must stop walking when he wants to cut."
  end

  def testCutWhenFalling
    @samsson.update # zjisti, ze ma pod sebou volno a zacne padat
    assert @samsson.falling?
    @samsson.space_func_on
    assert_equal false, (@samsson.state =~ /sword-fighting/), "Warior can't cut when he's falling."
  end
end # class TestWarior
