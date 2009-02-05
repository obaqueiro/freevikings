# testvikingstate.rb
# igneus 5.2.2009

require 'vikingstate2.rb'

class TestVikingState < Test::Unit::TestCase

  include FreeVikings::New

  def setup
    @s = VikingState.new do |s|
      s.table = {
        :standing => [:walking, :sitting],
        :walking => [:standing],
        :sitting => [:standing]
      }
      s.set_initial :sitting
    end
  end

  def testHasTableWriter
    s = VikingState.new
    assert_respond_to s, :table=, "Method needed to assign table of states"
  end

  # ===========================

  def setup1
    @s = VikingState.new
    @s.table = {:st1 => [:st2], :st2 => [:st1]}
  end

  def testTableCannotBeAssignedTwice
    setup1
    assert_raise(RuntimeError, "Exception must be raised, because table of "\
                 "states mustn't be assigned twice.") do
      @s.table = {}
    end
  end

  def testCannotChangeStateWithoutSettingInitial
    setup1
    @s = VikingState.new
    @s.table = {:st1 => [:st2], :st2 => [:st1]}
    assert_raise(RuntimeError, "Initial state hsn't been set. Method 'set' "\
                 "must fail.") do
      @s.set :st1
    end
  end

  # ==============================

  def testSetStateWhichCannotFollowImmediatelly
    assert_raise(VikingState::StateCannotFollowException,
                 ":walking cannot immediatelly follow :sitting - exception "\
                 "must be raised.") do
      @s.set :walking
    end
  end

  def testStateChanged
    @s.set :standing
    assert_equal :standing, @s.state
  end

  def testSetBangShortcutsDefined
    assert_respond_to @s, :walking!, "As soon as state table is assigned, "\
    "'bang methods' for more readable state setting should be defined."
  end

  def testBangMethodWorks
    @s.standing!
    assert_equal :standing, @s.state
  end

  def testPredicatesDefined
    assert_respond_to @s, :walking?, "'table=' should also define predicates"\
    "to ask 'is this state now?'"
  end

  def testPredicatesWork
    assert @s.sitting?
    assert ! @s.walking?
  end
end
