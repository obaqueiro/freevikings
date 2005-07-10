# testlocation.rb
# igneus 21.2.2005

# Sada testovych pripadu pro objekty Location.

require 'test/unit'

require 'mockclasses.rb'

require 'location.rb'

class TestLocation < Test::Unit::TestCase

  include FreeVikings

  def rect
    Rectangle.new 90, 90, 60, 60
  end

  def solid
    true
  end

  def setup
    @loc = Location.new(Mock::TestingMapLoadStrategy.new)
    @sprite = Sprite.new
  end

  def testBlocksOnRect
    assert_equal 4, @loc.map.blocks_on_rect([0.2,0.2,Map::TILE_SIZE*1.2,Map::TILE_SIZE*1.2]).size
  end

  def testSpritesOnRect
    sprite = Sprite.new([90,90])
    @loc.add_sprite sprite
    assert_equal 1, @loc.sprites_on_rect(Rectangle.new(80,80,20,20)).size, "I made one sprite waiting on position [12,12], so there must be one found."
  end

  def testTopLeftValidPosition
    valid_position = [3 * Map::TILE_SIZE, 3 * Map::TILE_SIZE]
    assert @loc.is_position_valid?(@sprite, valid_position), "Sprite does not collide with any of the blocks - it's position should be considered valid."
  end

  def testTopLeftInvalidPosition
    invalid_position = [0,0]
    assert_equal false, @loc.is_position_valid?(@sprite, invalid_position), "Sprite in this position collides with the solid blocks, it's position should be considered invalid."
  end

  # Horni i levy okraj sprajtu tesne hranici s pevnymi bloky. Presto by posice
  # mela byt platna.

  def testValidPositionOnTheTilesEdge
    assert @loc.is_position_valid?(@sprite, [Map::TILE_SIZE*2, Map::TILE_SIZE]), "Sprite is on the edge of the valid zone, but it's position should still be considered valid."
  end

  def testAreaFree
    assert(@loc.area_free?(self.rect), "Specified rectangular area is free.")
  end

  # Mam problem, vikingove chodi s nohama asi 10px pod urovni podlahy.
  # To by nemelo byt mozne.

  def testInvalidPositionWithFeetInTheBlock
    position = [1.5*Map::TILE_SIZE, @loc.background.h - (@sprite.image.h + Map::TILE_SIZE/2)]
    assert_equal false, @loc.is_position_valid?(@sprite, position), "Sprite's position mustn't be considered valid when the sprite has it's bottom edge in the solid block"
  end

  def testLocationAttrSet
    @loc.add_sprite @sprite
    assert_equal @loc, @sprite.location, "When the sprite is added to the location, it's attribute location should be set as a pointer to the location object."
  end

  def testLocationAttrUnsetAfterDelete
    @loc.add_sprite @sprite
    @loc.delete_sprite @sprite
    assert_instance_of NullLocation, @sprite.location, "When the sprite is deleted from the location, it's attribute location must be set to a NullLocation instance."
  end

  def testRectInside
    assert @loc.rect_inside?(Rectangle.new(2,2,5,5)), "Rectangle [2,2,5,5] is inside the location."
  end

  def testSolidStaticObjectMakesPositionInvalid
    assert_equal true, @loc.is_position_valid?(self, rect), "Now the position is valid, area is free."
    @loc.map.static_objects.add self
    assert_equal false, @loc.is_position_valid?(self, rect), "Position isn't valid, it's a solid static object there."
  end

end
