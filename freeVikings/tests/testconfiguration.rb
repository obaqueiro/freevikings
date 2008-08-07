# testconfiguration.rb
# igneus 7.8.2008

require 'configuration.rb'

class TestConfiguration < Test::Unit::TestCase

  def setup
    super

    @c1 = Configuration.new
    @c2 = Configuration.new
  end

  def testApply
    @c1['a'] = 1
    @c2['a'] = 2
    @c1.apply(@c2)
    assert_equal @c1['a'], 2
  end

  def testDoNotApplyNil
    @c1['a'] = 1
    @c2['a'] = nil
    @c1.apply(@c2)
    assert_equal @c1['a'], 1
  end

end
