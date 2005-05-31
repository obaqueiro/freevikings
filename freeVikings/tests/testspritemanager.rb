# testspritemanager.rb
# igneus 13.2.2005

# Testove pripady pro tridu SpriteManager

require 'rubyunit'

require 'spritemanager.rb'
require 'location.rb'
require 'mockclasses.rb'
require 'sprite.rb'

module FreeVikings
  GFX_DIR = "../gfx"
end

class TestSpriteManager < RUNIT::TestCase

  include FreeVikings
  include FreeVikings::Mock

  def setup
    @map = Location.new(TestingMapLoadStrategy.new)
    @manager = SpriteManager.new(@map)
    @sprite = Sprite.new([90,90])
  end

  def testSpritesOnRect
    @manager.add @sprite
    assert_equal @sprite, @manager.sprites_on_rect([85,85,60,60])[0], "There must be one sprite. I made it to be there."
  end

  def testSpritesOnRectFindsMoreSprites
    @manager.add @sprite
    @manager.add Sprite.new([82,82])
    @manager.add Sprite.new([140,140])
    assert_equal 3, @manager.sprites_on_rect([80,80,60,60]).size, "There are two sprites colliding with the specified rectangle."
  end

  def testSpritesOnRectDoesNotFindNotCollidingSprites
    @manager.add Sprite.new([120,120])
assert_equal 0, @manager.sprites_on_rect([10,10,10,10]).size, "The only sprite added does not collide with the specified rectangle."
  end

end
