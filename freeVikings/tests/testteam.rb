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

  def testPreviousValue
    assert_equal @viking3, @team.previous, "'previous' should return the member before the active."
  end

  def testRightActiveMemberAfterNext
    @team.next
    assert_equal @viking2, @team.active, "After next the next member should be considered active."
  end

  def testRightActiveMemberAfterPrevious
    @team.previous
    assert_equal @viking3, @team.active, "Call to previous should change the active member pointer."
  end

  def testExceptionIfNoMoreMemberAliveToBeMadeActiveOnNext
    @team.each {|v| v.destroy }
    assert_exception (Team::NotATeamMemberAliveException) {
      @team.next
    }
  end

  def testExceptionIfNoMoreMemberAliveToBeMadeActiveOnPrevious
    @team.each {|v| v.destroy }
    assert_exception (Team::NotATeamMemberAliveException) {
      @team.previous
    }
  end

  def testAliveSizeAllAlive
    assert_equal 3, @team.alive_size
  end

  def testAliveSizeAfterMemberLoss
    @viking1.destroy
    assert_equal 2, @team.alive_size
  end

  def testSetActive
    @team.active = @viking2
    assert_equal @viking2, @team.active, "Olle has been set active, he must be active."
  end

  def testSetActiveNonMemberObject
    @team.active = Viking.new 'Sinn Curwin'
    assert_equal @viking1, @team.active, "A non-member has been set active, it should have had absolutely no effect."
  end
end
