#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Unit tests for freeVikings.
# All files '$PWD/test*.rb' are required and all subclasses 
# of Test::Unit::TestCase ran.

require 'test/unit/testsuite'

require 'fvdef.rb' # base constants of the FreeVikings module
# Not all the constants are independent on the current working
# directory. So we must redefine those dependent ones:
module FreeVikings
  GFX_DIR = '../gfx'
end

# Run tests of compiled extensions if extensions are available
begin
  require '../ext/test/test.rb'
  $extensions_loaded = true
rescue LoadError => le
  puts "+++ COULD NOT LOAD TESTS OF THE COMPILED EXTENSIONS. (#{le.message})"
  $extensions_loaded = false
end

# SchwerEngine: Bundle where a lot of freeVikings code has been moved.
# It is needed for most fV classes to work.
require 'schwerengine/schwerengine.rb' 
SchwerEngine.config = FreeVikings
SchwerEngine.init
include SchwerEngine

# require all test source files
test_files = Dir['test*.rb']
exclude_files = [] # ['testlocation.rb', 'testviking.rb', 'testwarior.rb', 'testshielder.rb', 'testsprinter.rb']
test_files.each {|t| 
  unless exclude_files.include? t
    require t
  end
}

class FreeVikingsTestSuite < Test::Unit::TestSuite
  def self.suite
    suite = Test::Unit::TestSuite.new("freeVikings test suite")
    
    ObjectSpace.each_object(Class) do |klass|
      if klass < Test::Unit::TestCase then
        suite << klass.suite    
      end
    end

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
