# testlock.rb
# igneus 30.7.2005

require 'test/unit'

require 'lock.rb'

class TestLock < Test::Unit::TestCase

  def setup
    @lock = FreeVikings::Lock.new
  end

  def testIsLockedWhenInitialized
    assert @lock.locked?, "The Lock must be locked after initialization."
  end

  def testUnlockByTheKeyOfSameColour
    key = FreeVikings::Key.new
    @lock.unlock(key)
    assert_equal false, @lock.locked?, "The Lock was unlocked by the Key of the same colour, so it must not be locked now."
  end
end
