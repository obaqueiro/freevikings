# testactiveobject.rb
# igneus 16.6.2005

# ActiveObject is an entity of the freeVikings game world, which
# doesn't change it's state or position from it's own initiative
# (it means ActiveObjects don't need to be updated regularly).
# It's only informed when something happens to it (a player comes and
# presses the 'activate' or 'unactivate' key or some weapon hurts the
# ActiveObject).

require 'test/unit'

require 'activeobject.rb'

class TestActiveObject < Test::Unit::TestCase

  def setup
    @object = FreeVikings::ActiveObject.new
  end

  def testActiveObjectClassExists
    assert_kind_of Class, FreeVikings::ActiveObject, "The class 'ActiveObject' must exist at first."
  end

  def testMethodActivateExists
    assert_respond_to @object, :activate, "ActiveObject should have a method called 'activate' which is called when the player pushes the 'S' key over it."
  end

  def testMethodDeactivateExists
assert_respond_to @object, :deactivate, "ActiveObject should have a method called 'deactivate' which is called when the player pushes the 'F' key over it."
  end
end
