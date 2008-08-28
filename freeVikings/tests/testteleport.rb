# testteleport.rb
# igneus 28.8.2008

require 'teleport.rb'

class TestTeleport < Test::Unit::TestCase

  def setup
  end

  def testWrongDestination
    assert_raise(ArgumentError, "Destination must be Teleport, Rectangle or Array; others must cause exception.") {
      Teleport.new [0,0], "Destination of type String"
    }
  end
end
