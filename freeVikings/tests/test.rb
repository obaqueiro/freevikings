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
require 'testvikingstate.rb'

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
    suite << TestVikingState.suite

    return suite
  end
end

if ARGV[0] =~ /^[gG][tT][kK]$/ then
  require 'testrunner.rb'
  trm = Test::Unit::UI::GTK
else
  require 'test/unit/ui/console/testrunner'
  trm = Test::Unit::UI::Console
end

trm::TestRunner.run(FreeVikingsTestSuite)
