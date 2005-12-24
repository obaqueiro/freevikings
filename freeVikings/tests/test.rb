#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Unit tests for freeVikings.

require 'test/unit/testsuite'

require 'fvdef.rb' # base constants of the FreeVikings module
# Not all the constants are independent on the current working
# directory. So we must redefine those dependent ones:
module FreeVikings
  GFX_DIR = '../gfx'
end

# Some people don't compile the extensions, but they should be able to
# run tests, so here is a simple way not to load the extensions if
# they don't exist.
begin
  require '../ext/test/test.rb'
  $extensions_loaded = true
rescue LoadError => le
  puts "+++ COULD NOT LOAD TESTS OF THE COMPILED EXTENSIONS. (#{le.message})"
  $extensions_loaded = false
end

# Bundle where a lot of freeVikings code has been moved.
# It is needed for most fV classes to work.
require 'schwerengine/schwerengine.rb' 
SchwerEngine.config = FreeVikings
include SchwerEngine

require 'testlocation.rb'
require 'testxmllocloadstrategy.rb'
require 'testshield.rb'
require 'testviking.rb'
require 'testwarior.rb'
require 'testteam.rb'
require 'testrexml.rb'
require 'testsophisticatedspritestate.rb'
require 'testvikingstate.rb'
require 'testvikingstatetostring.rb'
require 'testcollisiontest.rb'
require 'testgroup.rb'
require 'testspritemanager.rb'
require 'testmonsterscript.rb'
require 'testinventory.rb'
require 'testmonster.rb'
require 'testsword.rb'
require 'testtimelock.rb'
require 'testbottompanelstate.rb'
require 'testbottompanel.rb'
require 'testlock.rb'
require 'testkey.rb'
require 'teststructuredworld.rb'
require 'testtalk.rb'
require 'testselectivegroup.rb'
require 'testtiledlocationloadstrategy.rb'

class FreeVikingsTestSuite

  def self.suite
    suite = Test::Unit::TestSuite.new("freeVikings test suite")

    if $extensions_loaded then
      suite << FreeVikingsExtensoinsTestSuite.suite
    end

    suite << TestLocation.suite
    suite << TestXMLLocationLoadStrategy.suite
    suite << TestShield.suite
    suite << TestViking.suite
    suite << TestWarior.suite
    suite << TestTeam.suite
    suite << TestExploreREXML.suite
    suite << TestSophisticatedSpriteState.suite
    suite << TestVikingState.suite
    suite << TestVikingStateToString.suite
    suite << TestCollisionTest.suite
    suite << TestGroup.suite
    suite << TestSpriteManager.suite
    suite << TestMonsterScript.suite
    suite << TestInventory.suite
    suite << TestMonster.suite
    suite << TestSword.suite
    suite << TestTimeLock.suite
    suite << TestBottomPanelState.suite
    suite << TestBottomPanel.suite
    suite << TestLock.suite
    suite << TestKey.suite
    suite << TestStructuredWorld.suite
    suite << TestTalk.suite
    suite << TestSelectiveGroup.suite
    suite << TestTiledLocationLoadStrategy.suite

    return suite
  end
end

verbosity = Test::Unit::UI::VERBOSE

if ARGV[0] =~ /^[gG][tT][kK]$/ then
  puts 'GTK UI'
  require 'testrunner.rb'
  trm = Test::Unit::UI::GTK
  trm::TestRunner.run(FreeVikingsTestSuite, verbosity)
elsif ARGV[0] =~ /^[tT][kK]$/ then
  puts 'Tk UI'
  require 'test/unit/ui/tk/testrunner'
  trm = Test::Unit::UI::Tk
  trm::TestRunner.run(FreeVikingsTestSuite)
else
  require 'test/unit/ui/console/testrunner'
  trm = Test::Unit::UI::Console
  trm::TestRunner.run(FreeVikingsTestSuite, verbosity)
end
