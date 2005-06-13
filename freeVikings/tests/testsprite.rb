# testsprite.rb
# igneus 21.2.2005

# Sada testovych pripadu pro tridu Sprite. S testy jsem otalel dlouho,
# ale ted chci tridu vycistit, tak budou testici potreba.

require 'test/unit'

require 'sprite.rb'

class TestSprite < Test::Unit::TestCase

  include FreeVikings

  STARTPOS = [90,90]

  def setup
    @sprite = Sprite.new(STARTPOS)
  end

  def testSpriteSetsUpItsPositionCorrectly
    assert_equal 90, @sprite.left, "It must be 90. I've set it to be 90."
    assert_equal 90, @sprite.top, "It must be 90. I've set it to be 90."
  end

  def testSpriteInitWithWidthAndHeight
    s = Sprite.new([90,90,12,5])
    assert_equal 12, s.rect.w
    assert_equal 5, s.rect.h
  end

  def testKilledIsNotAlive
    @sprite.destroy
    assert_equal false, @sprite.alive?
  end
end
