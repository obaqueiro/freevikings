# ext/test/test.rb
# igneus 7.6.2005

# Automaticke testy pro kompilovana rozsireni interpretu Ruby dodavana
# jako soucast hry freeVikings

require 'test/unit'

# bundle share library with all the C++ written classes:
require 'ext/Extensions'

require 'ext/test/testextensionrect.rb'
require 'ext/test/testextensionrectanglerectfeatures.rb'
require 'ext/test/testextmap.rb'

class FreeVikingsExtensoinsTestSuite
  
  def self.suite
    suite = Test::Unit::TestSuite.new

    suite << TestExtensionRectangle.suite
    suite << TestExtensionRectangleRectFeatures.suite
    suite << TestExtensionMap.suite

    suite
  end
end
