# testlocation.rb
# igneus 21.2.2005

# Sada testovych pripadu pro objekty Location.

require 'rubyunit'

require 'mockclasses.rb'

require 'location.rb'

class TestLocation < RUNIT::TestCase

  include FreeVikings

  def setup
    @loc = Location.new(Mock::TestingMapLoadStrategy.new)
    @sprite = Sprite.new
  end

  def testBlocksOnRect
    assert_equal 4, @loc.blocks_on_rect([0.2,0.2,Map::TILE_SIZE*1.2,Map::TILE_SIZE*1.2]).size
  end

  def testSpritesOnRect
    sprite = Sprite.new([90,90])
    @loc.add_sprite sprite
    assert_equal 1, @loc.sprites_on_rect([80,80,20,20]).size, "I made one sprite waiting on position [12,12], so there must be one found."
  end

  def testTopLeftValidPosition
    valid_position = [3 * Map::TILE_SIZE, 3 * Map::TILE_SIZE]
    assert @loc.is_position_valid?(@sprite, valid_position), "Sprite does not collide with any of the blocks - it's position should be considered valid."
  end

  def testTopLeftInvalidPosition
    invalid_position = [0,0]
    assert_nil @loc.is_position_valid?(@sprite, invalid_position), "Sprite in this position collides with the solid blocks, it's position should be considered invalid."
  end

  # Horni i levy okraj sprajtu tesne hranici s pevnymi bloky. Presto by posice
  # mela byt platna.

  def testValidPositionOnTheTilesEdge
    assert @loc.is_position_valid?(@sprite, [Map::TILE_SIZE*2, Map::TILE_SIZE]), "Sprite is on the edge of the valid zone, but it's position should still be considered valid."
  end

  # Mam problem, vikingove chodi s nohama asi 10px pod urovni podlahy.
  # To by nemelo byt mozne.

  def testInvalidPositionWithFeetInTheBlock
    position = [1.5*Map::TILE_SIZE, @loc.background.h - (@sprite.image.h + Map::TILE_SIZE/2)]
    assert_nil @loc.is_position_valid?(@sprite, position), "Sprite's position mustn't be considered valid when the sprite has it's bottom edge in the solid block"
  end

  def testLocationAttrSet
    @loc.add_sprite @sprite
    assert_equal @loc, @sprite.location, "When the sprite is added to the location, it's attribute location should be set as a pointer to the location object."
  end

  def testLocationAttrUnsetAfterDelete
    @loc.add_sprite @sprite
    @loc.delete_sprite @sprite
    assert_equal nil, @sprite.location, "When the sprite is deleted of the location, it's attribute location must be set to nil."
  end

end
