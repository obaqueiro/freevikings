# testextspritemanager.rb
# igneus 8.4.2005
# Testy pro SpriteManager prepsany v C

# tested so lib:
require 'ext/extspritemanager'

require 'sprite'
require 'tests/mockclasses'

class TestExtensionSpriteManager < RUNIT::TestCase

  def setup
    @manager = FreeVikings::Extensions::SpriteManager.new
    @sprite = FreeVikings::Sprite.new([90,90])
  end

  def testModuleExists
    assert((FreeVikings::Extensions).is_a?(Module), 'In the shared extension there is the FreeVikings::Extensions module defined.')
  end

  def testSpriteManagerClassExists
    assert((FreeVikings::Extensions::SpriteManager).is_a?(Class), 'In the shared extension there is the FreeVikings::Extensions::SpriteManager class defined.')
  end

  def testMethodAddSpriteExists
    assert_respond_to(:add, @manager, "SpriteManager must have an 'add' method.")
  end

  def testMethodIncludeExists
    assert_respond_to(:include?, @manager, "SpriteManager must have an 'include?' method.")
  end

  def testIncludesAddedSprite
    @manager.add @sprite
assert(@manager.include?(@sprite), 'The sprite was just added to the manager, it must know about it!')
  end
end
