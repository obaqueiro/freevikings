#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Automaticke testy pro freeVikings.

require 'rubyunit'

require 'testmap.rb'
require 'testspritemanager.rb'

class FreeVikingsTestSuite

  def suite
    suite = RUNIT::TestSuite.new

    suite.add TestMap.suite
    suite.add TestSpriteManager.suite

    return suite
  end
end

RUNIT::CUI::TestRunner.new(STDERR, $OPT_w)
