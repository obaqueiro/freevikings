# ext/test/test.rb
# igneus 7.6.2005

# Automaticke testy pro kompilovana rozsireni interpretu Ruby dodavana
# jako soucast hry freeVikings

require 'test/unit'

require 'ext/test/testextensionrect.rb'
require 'ext/test/testextensionrectanglerectfeatures.rb'

class FreeVikingsExtensoinsTestSuite
  
  def self.suite
    suite = Test::Unit::TestSuite.new

    suite << TestExtensionRectangle.suite
    suite << TestExtensionRectangleRectFeatures.suite

    suite
  end
end
