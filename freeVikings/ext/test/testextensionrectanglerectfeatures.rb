# testextensionrectanglerectfeatures.rb
# igneus 7.6.2005

# Testy napsane puvodne pro FreeVikings::Rectangle aplikovane
# na FreeVikings::Extensions::Rectangle::Rectangle

require 'tests/testrect.rb'

class TestExtensionRectangleRectFeatures < TestRect

  def setup
    @R = FreeVikings::Extensions::Rectangle::Rectangle
    @r1 = @R.new 60,60,60,60
  end
end
