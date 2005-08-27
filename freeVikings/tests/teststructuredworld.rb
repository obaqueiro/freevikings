# teststructuredworld.rb
# igneus 27.8.2005

require 'test/unit'

require 'structuredworld.rb'

class TestStructuredWorld < Test::Unit::TestCase

  include FreeVikings

  def testLongPassword
    too_long_password = "aaa66"
    assert_raise(ArgumentError, "Password \"#{too_long_password}\" is too long. An exception must be thrown.") do
      StructuredWorld.new('../locs/TestsCampaign/AncientLevelSet', too_long_password)
    end
  end
end
