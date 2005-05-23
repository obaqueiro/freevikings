#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Automaticke testy pro freeVikings.

require 'test/unit/testsuite'

require 'testlocation.rb'
require 'testxmllocloadstrategy.rb'
require 'testmap.rb'
require 'testspritemanager.rb'
require 'testsprite.rb'
require 'testviking.rb'
require 'testvelocity.rb'
require 'testteam.rb'
require 'testrect.rb'
require 'testrexml.rb'
require 'testoldvikingstate.rb'

require 'ext/test/test.rb'

class FreeVikingsTestSuite

  def self.suite
    suite = Test::Unit::TestSuite.new

    suite << TestLocation.suite
    suite << TestXMLLocationLoadStrategy.suite
    suite << TestMap.suite
    suite << TestSpriteManager.suite
    suite << TestSprite.suite
    suite << TestViking.suite
    suite << TestVelocity.suite
    suite << TestTeam.suite
    suite << TestRect.suite
    suite << TestExploreREXML.suite
    suite << TestOldVikingState.suite

    suite << FreeVikingsExtensionsTestSuite.suite

    return suite
  end
end

# load Log4r configuration:
require 'log4r/configurator'
Log4r::Configurator.load_xml_file('../log4rconfig.xml')
Log4r::Logger.global.level = Log4r::OFF # vystup testu nesmi byt rusen
#

if ARGV[0] =~ /^[gG][tT][kK]$/ then
  require 'testrunner.rb'
  trm = Test::Unit::UI::GTK
else
  require 'test/unit/ui/console/testrunner'
  trm = Test::Unit::UI::Console
end

trm::TestRunner.run(FreeVikingsTestSuite, Test::Unit::UI::VERBOSE)
