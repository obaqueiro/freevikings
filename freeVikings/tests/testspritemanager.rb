# testspritemanager.rb
# igneus 13.2.2005

# Testove pripady pro tridu SpriteManager

require 'testgroup.rb'

require 'spritemanager.rb'
require 'mockclasses.rb'

class TestSpriteManager < TestGroup

  include FreeVikings
  include FreeVikings::Mock

  def setup
    @map = Location.new(TestingMapLoadStrategy.new)
    @group = @manager = SpriteManager.new
    @object = @sprite = Sprite.new([90,90])
  end
end
