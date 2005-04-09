# testextspritemanager.rb
# igneus 8.4.2005
# Testy pro SpriteManager prepsany v C

# tested so lib:
require 'ext/extspritemanager'

require 'location.rb'
require 'tests/mockclasses'

class TestExtensionSpriteManager < RUNIT::TestCase

  include FreeVikings

  def setup
    @loc = Location.new(Mock::TestingMapLoadStrategy.new)
  end

  def testClassExists
    assert_no_exception do
      sm = FreeVikings::Extensions::SpriteManager.new(@loc)
    end
  end
end
