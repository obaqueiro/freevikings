#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Schwerengine unit tests
require 'test/unit/testsuite'

require_relative '../lib/schwerengine.rb'
SchwerEngine.init

require 'mockclasses.rb'

module SchwerEngineConfig
  GFX_DIR = '../gfx'
end

SchwerEngine.config = SchwerEngineConfig

module SchwerEngine::Tests
  # require all test source files
  test_files = Dir['test*.rb']
  test_files.each {|t| require t}
end

class SchwerEngine::Tests::TestSuite

  def self.suite
    suite = Test::Unit::TestSuite.new("SchwerEngine test suite")

    ObjectSpace.each_object(Class) do |klass|
      if klass < Test::Unit::TestCase then
        suite << klass.suite    
      end
    end

    return suite
  end
end



require 'test/unit/ui/console/testrunner'

verbosity = Test::Unit::UI::VERBOSE
Test::Unit::UI::Console::TestRunner.run(SchwerEngine::Tests::TestSuite,
                                        verbosity)
