#!/usr/bin/ruby

# test.rb
# igneus 13.2.2005

# Automaticke testy pro freeVikings.

require 'rubyunit'

require 'testlocation.rb'
require 'testmap.rb'
require 'testspritemanager.rb'
require 'testsprite.rb'
require 'testviking.rb'
require 'testvelocity.rb'
require 'testteam.rb'
require 'testrect.rb'

class FreeVikingsTestSuite

  def suite
    suite = RUNIT::TestSuite.new

    suite.add TestLocation.suite
    suite.add TestMap.suite
    suite.add TestSpriteManager.suite
    suite.add TestSprite.suite
    suite.add TestViking.suite
    suite.add TestVelocity.suite
    suite.add TestTeam.suite
    suite.add TestRect.suite

    return suite
  end
end

RUNIT::CUI::TestRunner.new(STDERR, $OPT_w)
