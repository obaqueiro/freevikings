# testextensionrect.rb
# igneus 7.6.2005

# Sada testovych pripadu pro tridu FreeVikings::Extensions::Rectangle

require 'test/unit'

require 'ext/Rectangle'

class TestExtensionRectangle < Test::Unit::TestCase

  include FreeVikings::Extensions::Rectangle

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

end
