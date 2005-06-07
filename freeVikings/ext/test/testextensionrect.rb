# testextensionrect.rb
# igneus 7.6.2005

# Sada testovych pripadu pro tridu FreeVikings::Extensions::Rectangle

require 'test/unit'

require 'ext/Rectangle'

class TestExtensionRectangle < Test::Unit::TestCase

  include FreeVikings::Extensions::Rectangle

  def setup
    @r = Rectangle.new 20, 12, 30, 15
  end

  def testClassExists
    assert_kind_of(Class, FreeVikings::Extensions::Rectangle::Rectangle, "There should be a class FreeVikings::Extensions::Rectangle.")
  end

  def testDefaultConstructor
    assert_kind_of(Rectangle, Rectangle.new())
  end

  def testConstructorWithParameters
    assert_kind_of(Rectangle, Rectangle.new(0,0,1,1))
  end

  def testEmptyRect
    empty = Rectangle.new
    assert_equal 0, empty.left
    assert_equal 0, empty.top
    assert_equal 0, empty.width
    assert_equal 0, empty.height
  end

  def testNonemptyRect
    assert_equal 20, @r.left
    assert_equal 12, @r.top
    assert_equal 30, @r.width
    assert_equal 15, @r.height
  end

  def testIndexing
    assert_equal @r[0], @r.left
    assert_equal @r[1], @r.top
    assert_equal @r[2], @r.width
    assert_equal @r[3], @r.height
  end

  def testShortNamedMethods
    assert_equal @r.width, @r.w
    assert_equal @r.height, @r.h
  end

  def testLeftAtrWriter
    @r.left = 9003
    assert_equal 9003, @r.left
  end

  def testTopAttrWriter
    @r.top = 3009
    assert_equal 3009, @r.top
  end

  def testHeightAttrWriter
    @r.h = 162
    assert_equal 162, @r.h
  end

  def testWidthAttrWriter
    @r.w = 261
    assert_equal 261, @r.w
  end

end
