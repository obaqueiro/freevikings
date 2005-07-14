#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Automaticke testy pro freeVikings.

require 'test/unit/testsuite'

# Some people don't compile the extensions, but they should be able to
# run tests, so here is a simple way not to load the extensions if
# they don't exist.
begin
  require '../ext/test/test.rb'
  $extensions_loaded = true
rescue LoadError
  puts '+++ COULD NOT LOAD THE COMPILED EXTENSIONS.'
  $extensions_loaded = false
end

require 'testlocation.rb'
require 'testxmllocloadstrategy.rb'
require 'testmap.rb'
require 'testentity.rb'
require 'testsprite.rb'
require 'testitem.rb'
require 'testarrow.rb'
require 'testshield.rb'
require 'testviking.rb'
require 'testwarior.rb'
require 'testteam.rb'
require 'testrect.rb'
require 'testrexml.rb'
require 'testsophisticatedspritestate.rb'
require 'testvikingstate.rb'
require 'testvikingstatetostring.rb'
require 'testcollisiontest.rb'
require 'testimagebank.rb'
require 'testactiveobject.rb'
require 'testgroup.rb'
require 'testspritemanager.rb'
require 'testactiveobjectmanager.rb'
require 'testitemmanager.rb'
require 'testmonsterscript.rb'
require 'testinventory.rb'
require 'testmonster.rb'
require 'testsword.rb'

class FreeVikingsTestSuite

  def self.suite
    suite = Test::Unit::TestSuite.new

    if $extensions_loaded then
      suite << FreeVikingsExtensoinsTestSuite.suite
    end

    suite << TestLocation.suite
    suite << TestXMLLocationLoadStrategy.suite
    suite << TestMap.suite
    suite << TestEntity.suite
    suite << TestSprite.suite
    suite << TestItem.suite
    suite << TestArrow.suite
    suite << TestShield.suite
    suite << TestViking.suite
    suite << TestWarior.suite
    suite << TestTeam.suite
    suite << TestRect.suite
    suite << TestExploreREXML.suite
    suite << TestSophisticatedSpriteState.suite
    suite << TestVikingState.suite
    suite << TestVikingStateToString.suite
    suite << TestCollisionTest.suite
    suite << TestImageBank.suite
    suite << TestActiveObject.suite
    suite << TestGroup.suite
    suite << TestSpriteManager.suite
    suite << TestActiveObjectManager.suite
    suite << TestItemManager.suite
    suite << TestMonsterScript.suite
    suite << TestInventory.suite
    suite << TestMonster.suite
    suite << TestSword.suite

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
