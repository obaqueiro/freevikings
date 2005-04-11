# testvikingstate.rb
# igneus 11.3.2005

# Sada testovych pripadu pro stavove prechody vikingu.
# (Potrebuji provest par optimalizacnich uprav a chci mit jistotu, ze nenadelam
# neporadek.)

require 'rubyunit'

require 'viking.rb'
require 'vikingstate.rb'

class TestVikingState < RUNIT::TestCase

  include FreeVikings

  def setup
    @viking = Viking.new([0,0])
  end

  def testLeftDirectionAfterMoveLeft
    @viking.move_left
    assert_equal "left", @viking.state.direction, "The direction must be left after move_left call."
  end

  def testRightDirectionAfterMoveRight
    @viking.move_right
    assert_equal "right", @viking.state.direction, "The direction must be right after move_right call."
  end

end
