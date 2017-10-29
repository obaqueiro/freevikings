# testrect3.rb
# igneus 12.12.2008

# Tests for rect3.rb; optimized rect must have the same functionality as
# the old one.

require 'testrect.rb'

class TestRect3 < TestRect

  def setup
    @R = Rectangle
    @r1 = @R.new 60,60,60,60
  end

  def testClass
    assert_equal 3, @R::RECTANGLE_VERSION
  end
end
