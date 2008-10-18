#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Schwerengine unit tests
require 'test/unit/testsuite'

require 'schwerengine.rb'
SchwerEngine.init

require 'mockclasses.rb'

module SchwerEngineConfig
  GFX_DIR = '../gfx'
end

SchwerEngine.config = SchwerEngineConfig

module SchwerEngine::Tests
  require 'testrect.rb'
  require 'testentity.rb'
  require 'testsprite.rb'
  require 'testitem.rb'
  require 'testgfxtheme.rb'
  require 'testmap.rb'
  require 'testmodel.rb'
  require 'testmodelloader.rb'
  require 'testtimelock.rb'
  require 'testgroup.rb'
  require 'testselectivegroup.rb'
  require 'testselectivegroup.rb'
end

class SchwerEngine::Tests::TestSuite

  def self.suite
    suite = Test::Unit::TestSuite.new("SchwerEngine test suite")

    suite << TestRect.suite
    suite << TestEntity.suite
    suite << TestSprite.suite
    suite << TestItem.suite
    suite << TestGfxTheme.suite
    suite << TestMap.suite
    suite << TestModel.suite
    suite << TestModelLoader.suite
    suite << TestTimeLock.suite
    suite << TestGroup.suite
    suite << TestSelectiveGroup.suite

    return suite
  end
end



if $0 == __FILE__ then
  require 'test/unit/ui/console/testrunner'

  verbosity = Test::Unit::UI::VERBOSE
  Test::Unit::UI::Console::TestRunner.run(SchwerEngine::Tests::TestSuite,
                                          verbosity)
end
