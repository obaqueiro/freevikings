# testsprite.rb
# igneus 21.2.2005

# Sada testovych pripadu pro tridu Sprite. S testy jsem otalel dlouho,
# ale ted chci tridu vycistit, tak budou testici potreba.

require 'rubyunit'

require 'sprite.rb'

class TestSprite < RUNIT::TestCase

  def setup
    @sprite = Sprite.new([90,90])
  end

  def testSpriteSetsUpItsPositionCorrectly
    assert_equal 90, @sprite.left, "It must be 90. I've set it to be 90."
    assert_equal 90, @sprite.top, "It must be 90. I've set it to be 90."
  end
end
