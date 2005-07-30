# testkey.rb
# igneus 31.7.2005

# Test cases for class Key

require 'testitem.rb'

require 'key.rb'

class TestKey < TestItem

  include FreeVikings

  # We pretend TestKey is a Viking which uses the Key.
  # 'location' and 'rect' method is here for this purpose.

  def location
    @location
  end

  def rect
    nil # with the mock Location used we don't need a real Rectangle
  end

  # Normal test stuff:

  def setup
    super
    @item = @key = Key.new([], Key::BLUE)

    @lock = Lock.new([], nil, Lock::BLUE)
    @location = TestingUnitedMapAndLocation.new([@lock])
  end

  def testUnlockCollidingLock
    @key.apply(self)
    assert_equal false, @lock.locked?, "Key collides with a Lock of the same colour, it should have unlocked it."
  end
end



class TestingUnitedMapAndLocation

  def initialize(static_objects_on_rect)
    @s_o_on_rect = static_objects_on_rect
  end

  def map
    self
  end

  def static_objects
    self
  end

  def members_on_rect(rect)
    @s_o_on_rect
  end
end
