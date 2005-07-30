# testlock.rb
# igneus 30.7.2005

require 'test/unit'

require 'lock.rb'
require 'key.rb'

class TestLock < Test::Unit::TestCase

  include FreeVikings

  def setup
    @position = []
    @lock = Lock.new(@position, nil, Lock::BLUE)
  end

  def testIsLockedWhenInitialized
    assert @lock.locked?, "The Lock must be locked after initialization."
  end

  def testUnlockByTheKeyOfSameColour
    key = Key.new(@position, Key::BLUE)
    @lock.unlock(key)
    assert_equal false, @lock.locked?, "The Lock was unlocked by the Key of the same colour, so it must not be locked now."
  end

  def testCannotBeUnlockedByAKeyOfDifferentColour
    key = Key.new(@position, Key::RED)
    @lock.unlock(key)
    assert_equal true, @lock.locked?, "The Lock cannot be unlocked by the Key of a different colour, so it is still locked."
  end

  def testUnlockAction
    @flag = true
    @lock.unlock_action = Proc.new { @flag = ! @flag }
    @lock.unlock(Key.new(@position, Key::BLUE)) 
    assert_equal false, @flag, "The unlock action should have changed the value of variable @flag."
  end

  def testThrowExceptionIfUnlockedByANonkey
    assert_raise(Lock::AttemptToUnlockByANonKeyToolException, "The Lock can only be unlocked by a Key instance. nil is not a Key, an exception must be thrown.") do
      @lock.unlock(nil)
    end
  end
end
