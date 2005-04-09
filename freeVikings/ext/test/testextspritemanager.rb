# testextspritemanager.rb
# igneus 8.4.2005
# Testy pro SpriteManager prepsany v C

# tested so lib:
require 'ext/extspritemanager'

require 'location.rb'
require 'sprite'
require 'tests/mockclasses'

class TestExtensionSpriteManager < RUNIT::TestCase

  include FreeVikings
  include FreeVikings::Extensions

  def setup
    @loc = Location.new(Mock::TestingMapLoadStrategy.new)
    @sprite = Sprite.new([90,90])
  end

  def testClassExists
    assert_no_exception do
      sm = FreeVikings::Extensions::SpriteManager.new(@loc)
    end
  end

  def testInclude?
    @manager = SpriteManager.new(@loc)
    @manager.add @sprite
    assert(@manager.include?(@sprite), 'SpriteManager must know about the sprite just added.')
  end
end
