# testextspritemanager.rb
# igneus 8.4.2005
# Testy pro SpriteManager prepsany v C

# tested shared lib:
require 'ext/extspritemanager'

require 'sprite'
require 'tests/mockclasses'

class TestExtensionSpriteManager < RUNIT::TestCase

  def setup
    @location = FreeVikings::Location.new(FreeVikings::Mock::TestingMapLoadStrategy.new)
    @manager = FreeVikings::Extensions::SpriteManager.new(@location)
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

  def testDoesNotIncludeTheSpriteWhichWasNotAdded
    assert_nil(@manager.include?(@sprite), 'The sprite wasn\'t added, manager should not know about it.')
  end

  def testDifferentManagersKnowAboutDifferentSprites
    @manager.add @sprite
    @manager2 = FreeVikings::Extensions::SpriteManager.new(@location)
    @manager2.add FreeVikings::Sprite.new([1000,1000])
    assert_nil(@manager2.include?(@sprite), "SpriteManagers shouldn't have their public sprites list, but every should have it's own, so we'll be able to have more than one SpriteManager.")
  end

  def testMethodDeleteExists
assert_respond_to(:delete, @manager, "SpriteManager must have a 'delete' method deleting a sprite from the manager's sprites list.")
  end
end
