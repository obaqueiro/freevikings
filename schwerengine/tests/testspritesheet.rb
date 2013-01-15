# testspritesheet.rb
# igneus 19.12.2008

require 'test/unit'

class TestSpriteSheet < Test::Unit::TestCase

  include SchwerEngine

  def testNew
    s = SpriteSheet.new('../gfx/nobody.tga', {'some' => Rectangle.new(0,0,30,30)})
    i = s['some']
    assert_equal 30, i.w
  end

  def testFrames
    s = SpriteSheet.new('../gfx/nobody.tga', {'some' => Rectangle.new(0,0,30,30)})
    assert_equal 1, s.frames
  end

  def test0Frames
    s = SpriteSheet.new('../gfx/nobody.tga', {})
    assert_equal 0, s.frames
  end

  def testNew2
    s = SpriteSheet.new2('../gfx/nobody.tga', 15,15, [:a, :b, :c, :d])
    assert_equal 4, s.frames
  end
end
