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
    @loc.add_sprite @samsson
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
    @samsson.fall # zjisti, ze ma pod sebou volno a zacne padat
    assert @samsson.falling?
    @samsson.space_func_on
    assert_equal false, @samsson.sword_fighting?, "Warior can't cut when he's falling."
  end

  def testShootWhenFalling
    @samsson.fall
    @samsson.d_func_on
    assert_equal false, @samsson.bow_stretching?, "Warior can't shoot when he is falling."
  end

  def testSwordFightingWorks
    message = "Warior#sword_fighting? is a small extension just for testing, but it is also tested, because it must be buggless to keep the tests useful."
    @samsson.space_func_on
    assert_equal true,  @samsson.sword_fighting?, message + "\nSamsson's sword should be in use now."
    @samsson.space_func_off
    assert_equal false, @samsson.sword_fighting?, message + "\nSamsson's sword shouldn't in use now."
  end

  def DrawnSwordDisappearesWhenWariorDies
    @samsson.space_func_on
    assert_equal 1, @loc.sprites.size, "There are two sprites in the MockLocation - the warior and his sword."
    @samsson.destroy
    assert_equal 0, @loc.sprites.size, "There should be no sprites in the location, the warior is dead and the sword should have disappeared."
  end

  def testReleaseArrowWithoutBowStretching
    assert_raise( FreeVikings::Warior::ReleaseArrowWithoutBowStretchingException, "The bow hasn't been stretched, it can't be able to shoot then.An exception should be thrown." ) do
      @samsson.release_arrow
    end
  end

  def testReleaseArrowWithAStretchedBow
    @samsson.d_func_on
    assert_nothing_raised("The bow has been stretched, so we should be able to release an arrow now. No exception should be thrown.") do
      @samsson.release_arrow
    end
  end
end # class TestWarior


# Male rozsireni standardni tridy Warior; slouzi akorat k tomu, aby testy byly
# prehlednejsi.
class FreeVikings::Warior
  def sword_fighting?
    @ability.active_ability == 'sword-fighting'
  end

  def bow_stretching?
    @ability.active_ability == 'bow-stretching'
  end

  def fall
    @state.fall
  end
end
# Mimochodem nadherne se tu ukazuje flexibilitu syntaxe jazyka Ruby.
# Kdyz nechci, nemusim vypisovat "module FreeVikings...",
# proste napisu "class FreeVikings::Warior" a Ruby tomu rozumi stejne dobre.
# Rozkosne uplatneni pravidla nejmensiho prekvapeni. O tehle moznosti jsem 
# nevedel, dokud jsem ji nevyzkousel.
