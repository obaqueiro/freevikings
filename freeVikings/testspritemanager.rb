# testspritemanager.rb
# igneus 13.2.2005

# Testove pripady pro tridu SpriteManager

require 'rubyunit'

require 'spritemanager.rb'
require 'map.rb'
require 'mockclasses.rb'
require 'sprite.rb'

include FreeVikings
include FreeVikings::Mock

class TestSpriteManager < RUNIT::TestCase

  def setup
    @map = Map.new(TestingMapLoadStrategy.new)
    @manager = SpriteManager.new(@map)
    @sprite = Sprite.new
  end

  attach_setup :setup

  def testTopLeftValidPosition
    valid_position = [1.5 * Map::TILE_SIZE, 1.5 * Map::TILE_SIZE]
    assert @manager.is_position_valid?(@sprite, valid_position), "Sprite does not collide with any of the blocks - it's position should be considered valid."
  end

  def testTopLeftInvalidPosition
    invalid_position = [0,0]
    assert_nil @manager.is_position_valid?(@sprite, invalid_position), "Sprite in this position collides with the solid blocks, it's position should be considered invalid."
  end

  # Horni i levy okraj sprajtu tesne hranici s pevnymi bloky. Presto by posice
  # mela byt platna.

  def testValidPositionOnTheTilesEdge
    assert @manager.is_position_valid?(@sprite, [Map::TILE_SIZE, Map::TILE_SIZE]), "Sprite is on the edge of the valid zone, but it's position should still be considered valid."
  end

  # Mam problem, vikingove chodi s nohama asi 10px pod urovni podlahy.
  # To by nemelo byt mozne.

  def testInvalidPositionWithFeetInTheBlock
    position = [1.5*Map::TILE_SIZE, @map.background.h - (@sprite.image.h + Map::TILE_SIZE/2)]
    assert_nil @manager.is_position_valid?(@sprite, position), "Sprite's position mustn't be considered valid when the sprite has it's bottom edge in the solid block"
  end

end
