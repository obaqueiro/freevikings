# testentity.rb
# igneus 19.6.2005

# Testy pro tridu Entity (supertrida vseho, co ma svuj obrazek a misto ve hre).

require 'test/unit'

class TestEntity # skip < Test::Unit::TestCase

  include SchwerEngine

  STARTPOS = [90,90]

  def setup
    @entity = Entity.new STARTPOS
  end

  def testSetsUpItsPositionCorrectly
    assert_equal 90, @entity.rect.left, "It must be 90. I've set it to be 90."
    assert_equal 90, @entity.rect.top, "It must be 90. I've set it to be 90."
  end

  def testInitWithWidthAndHeight
    e = Entity.new([90,90,12,5])
    assert_equal 12, e.rect.w
    assert_equal 5, e.rect.h
  end

  def testGetThemeImageThrowsErrorIfNullTheme
    assert_raise(Entity::NullThemeException) do
      @entity.get_theme_image('blue_grass')
    end
  end
end
