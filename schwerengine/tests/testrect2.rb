# testrect2.rb
# igneus 12.12.2008

# Tests for rect2.rb; optimized rect must have the same functionality as
# the old one.

require 'testrect.rb'

class TestRect2 < TestRect

  require 'rect2.rb'

  def setup
    @R = Rectangle
    @r1 = @R.new 60,60,60,60
  end

  def testClass
    assert_equal 2, @R::RECTANGLE_VERSION
  end
end
