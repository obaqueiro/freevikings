# ext/test/test.rb
# igneus 8.4.2005
# Automaticke testy pro zrychlovaci rozsireni napsana v kompilovanych
# jazycich.

require 'test/unit/testsuite'

require 'ext/test/testextspritemanager.rb'

class FreeVikingsExtensionsTestSuite

  def self.suite
    suite = Test::Unit::TestSuite.new

    suite << TestExtensionSpriteManager.suite

    return suite
  end
end