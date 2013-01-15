# testtimelock.rb
# igneus 22.7.2005

require 'test/unit'
require 'mockclasses.rb'

require 'timelock.rb'

class TestTimeLock < Test::Unit::TestCase

  include SchwerEngine
  include SchwerEngine::Mock

  def setup
    @ticker = CorruptedTicker.new
  end

  def testTimeLockIsInitiallyFree
    lock = TimeLock.new
    assert lock.free?, "The lock wasn't initialized by a number, so it must be free."
  end

  def testTimeLockInitializedByZeroIsFree
    lock = TimeLock.new 0
    assert lock.free?, "The lock was initialized by 0, it is free."
  end

  def testTimeLockIsNotFreeBeforeExpiry
    @ticker.now = 0
    lock = TimeLock.new 10, @ticker
    assert_equal false, lock.free?, "The lock is not free, because it is ten seconds before his expiry time."
  end

  def testTimeLockIsFreeAfterExpiry
    @ticker.now = 0
    lock = TimeLock.new 10, @ticker
    @ticker.now = 20
    assert lock.free?, "The lock is free after expiry time."
  end
end
