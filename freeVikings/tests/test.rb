#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Automaticke testy pro freeVikings.

require 'test/unit/testsuite'

require '../ext/test/test.rb'

require 'testlocation.rb'
require 'testxmllocloadstrategy.rb'
require 'testmap.rb'
require 'testspritemanager.rb'
require 'testsprite.rb'
require 'testarrow.rb'
require 'testshield.rb'
require 'testviking.rb'
require 'testwarior.rb'
require 'testvelocity.rb'
require 'testteam.rb'
require 'testrect.rb'
require 'testrexml.rb'
require 'testvikingstate.rb'
require 'testvikingstatetostring.rb'
require 'testcollisiontest.rb'
require 'testimagebank.rb'

class FreeVikingsTestSuite

  def self.suite
    suite = Test::Unit::TestSuite.new

    suite << FreeVikingsExtensoinsTestSuite.suite

    suite << TestLocation.suite
    suite << TestXMLLocationLoadStrategy.suite
    suite << TestMap.suite
    suite << TestSpriteManager.suite
    suite << TestSprite.suite
    suite << TestArrow.suite
    suite << TestShield.suite
    suite << TestViking.suite
    suite << TestWarior.suite
    suite << TestVelocity.suite
    suite << TestTeam.suite
    suite << TestRect.suite
    suite << TestExploreREXML.suite
    suite << TestVikingState.suite
    suite << TestVikingStateToString.suite
    suite << TestCollisionTest.suite
    suite << TestImageBank.suite

    return suite
  end
end

if ARGV[0] =~ /^[gG][tT][kK]$/ then
  puts 'GTK UI'
  require 'testrunner.rb'
  trm = Test::Unit::UI::GTK
elsif ARGV[0] =~ /^[tT][kK]$/
  puts 'Tk UI'
  require 'test/unit/ui/tk/testrunner'
  trm = Test::Unit::UI::Tk
  trm::TestRunner.run(FreeVikingsTestSuite)
  exit
else
  require 'test/unit/ui/console/testrunner'
  trm = Test::Unit::UI::Console
end

trm::TestRunner.run(FreeVikingsTestSuite, Test::Unit::UI::VERBOSE)
