# testprogramwalker.rb
# igneus 23.12.2008

require 'test/unit'
require 'programwalker'

class TestProgramWalker < Test::Unit::TestCase

  include FreeVikings

  def setup
    @cs = [:walk, :jump, :smile]
  end

  def testSingleCommand
    c = [:walk, 2]
    w = ProgramWalker.new c, @cs

    assert_equal c, w.next_command
    assert_equal false, w.running?, "program has just one command, so it has ended"
  end

  def testTwoCommands
    c = [[:walk, 2],
         [:jump, 'hell']]
    w = ProgramWalker.new c, @cs

    w.next_command
    assert_equal c[1], w.next_command
    assert_equal false, w.running?
  end

  def testNestedSets
    c = [
         [[:walk, 3], [:walk, 5]],
         [:walk, 7]
        ]
    w = ProgramWalker.new c, @cs

    assert_equal c[0][0], w.next_command
    assert_equal c[0][1], w.next_command
    assert_equal c[1], w.next_command
    assert_equal false, w.running?
  end

  def testRepeat
    c = [:repeat, 2, [:walk, 3]]
    w = ProgramWalker.new(c, @cs)

    assert_equal c[2], w.next_command
    assert_equal c[2], w.next_command
    assert_equal false, w.running?
  end

  def testRepeatSet
    c = [:repeat, 2, [[:walk, 1],
                      [:walk, 2]]]

    w = ProgramWalker.new c, @cs

    assert_equal [:walk, 1], w.next_command
    assert_equal [:walk, 2], w.next_command
    assert_equal [:walk, 1], w.next_command
    assert_equal [:walk, 2], w.next_command

    assert_equal false, w.running?
  end

  def testComplicated
    c = [
         [:repeat, 2, [[:walk, 1],
                       [:smile],
                       [:jump, 1]]],

         [[:jump, 17], 
          [[:walk, 3]],
          [:walk,4]],
         
         [:repeat, 3, [:jump, 1]]]
    w = ProgramWalker.new c, @cs

    assert_equal [:walk, 1], w.next_command
    assert_equal [:smile], w.next_command, "First smile assertion"
    assert_equal [:jump, 1], w.next_command
    assert_equal [:walk, 1], w.next_command
    assert_equal [:smile], w.next_command, "Second smile assertion"
    assert_equal [:jump, 1], w.next_command

    assert_equal [:jump, 17], w.next_command
    assert_equal [:walk, 3], w.next_command
    assert_equal [:walk, 4], w.next_command

    assert_equal [:jump, 1], w.next_command
    assert_equal [:jump, 1], w.next_command
    assert_equal [:jump, 1], w.next_command

    assert_equal false, w.running?
  end

  def testRepeatForever
    c = [:repeat, -1, [:walk, 1]]    
    w = ProgramWalker.new c, @cs

    10.times {
      assert_equal [:walk, 1], w.next_command
    }
  end

  def testForeverRepeatRunning
    c = [:repeat, -1, [:walk, 1]]    
    w = ProgramWalker.new c, @cs
    assert_equal true, w.running?
  end
end
