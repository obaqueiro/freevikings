# testteam.rb
# igneus 18.2.2005

# Sada testovych pripadu pro tridu Team

require 'rubyunit'

require 'team.rb'
require 'viking.rb'

class TestTeam < RUNIT::TestCase

  include FreeVikings

  def setup
    @viking1 = Viking.new 'Hans'
    @viking2 = Viking.new 'Olle'
    @viking3 = Viking.new 'Kurt'
    @team = Team.new(@viking1, @viking2, @viking3)
  end

  def testFirstMemberIsActiveOnTheStart
    assert_equal @viking1, @team.active, "On the start of the team\'s big mission, the first added member should be active, shouldn\'t he?"
  end

  def testNextValue
    assert_equal @viking2, @team.next, "Next should return the next member of the team."
  end

  def testLastValue
    assert_equal @viking3, @team.last, "Last should return the member before the active."
  end

  def testRightActiveMemberAfterNext
    @team.next
    assert_equal @viking2, @team.active, "After next the next member should be considered active."
  end

  def testRightActiveMemberAfterLast
    @team.last
    assert_equal @viking3, @team.active, "Call to last should change the active member pointer."
  end

  def testExceptionIfNoMoreMemberAliveToBeMadeActiveOnNext
    @team.each {|v| v.destroy }
    assert_exception (NotATeamMemberAliveException) {
      @team.next
    }
  end

  def testExceptionIfNoMoreMemberAliveToBeMadeActiveOnLast
    @team.each {|v| v.destroy }
    assert_exception (NotATeamMemberAliveException) {
      @team.last
    }
  end

  def testAliveSizeAllAlive
    assert_equal 3, @team.alive_size
  end

  def testAliveSizeAfterMemberLoss
    @viking1.destroy
    assert_equal 2, @team.alive_size
  end
end
