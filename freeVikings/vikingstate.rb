# vikingstate.rb
# igneus 24.1.2005

# Tridy pro stavy vikingu

require 'velocity.rb'

module FreeVikings

  GRAVITY = 400

  # Stavy, ktere jsou Previous, umoznuji vratit se volanim metody previous do
  # predchoziho stavu
  module Previousable
    def previous
      @viking.state = @last_state
    end
  end

  class VikingState
    # Supertrida pro tridy Stavu vikinga

    attr_reader :velocity_horiz
    attr_reader :velocity_vertic
    attr_reader :last_state

    def initialize(viking, last_state=nil)
      @viking = viking
      @velocity_horiz = Velocity.new
      @velocity_vertic = Velocity.new(0, GRAVITY)
    end

    def to_s
      ""
    end

    def direction
      ""
    end

    def moving?
      nil
    end

    def alive?
      true
    end

    def stop
    end

    def stuck
      nil
    end

    def destroy
      @viking.state = DeadVikingState.new(@viking, self)
    end

    def move_left
      nil
    end

    def move_right
      nil
    end

    def move_up
      nil
    end

    def move_down
      nil
    end

    # akce klavesy mezernik, zpravidla boj nebo pouziti specialni schopnosti

    def space_func
      nil
    end

    # akce klavesy s, zpravidla prechod do specialniho stavu

    def s_func
      nil
    end

    # akce klavesy F, zpravidla zruseni specialniho stavu vikinga

    def f_func
      nil
    end

    def dump
      "<id:#{id} vv:#{@velocity_vertic.value} vh:#{@velocity_horiz.value}>"
    end
  end # class VikingState

  class DeadVikingState < VikingState

    def to_s
      "dead"
    end

    def alive?
      nil
    end
  end # class DeadVikingState

  class StandingVikingState < VikingState
    def to_s
      "standing"
    end

    def move_left
      @viking.state = LeftWalkingVikingState.new(@viking, self)
    end

    def move_right
      @viking.state = RightWalkingVikingState.new(@viking, self)
    end
  end # class StandingVikingState

  class MovingVikingState < VikingState
    def moving?
      true
    end

    def stuck
      @viking.state = StuckedVikingState.new(@viking, self)
    end
  end # class MovingVikingState

  class WalkingVikingState < MovingVikingState
    # Supertrida pro tridy chuze, padani a splhani
    def stop
      @viking.state = StandingVikingState.new(@viking, self)
    end

    def to_s
      "moving_" + direction
    end
  end # class MovingVikingState

  class LeftWalkingVikingState < WalkingVikingState
    # viking jde doleva
    def initialize(viking, last_state)
      super(viking, last_state)
      @velocity_horiz.value = - (@viking.class::BASE_VELOCITY)
    end

    def direction
      "left"
    end

    def move_right
      @viking.state = RightWalkingVikingState.new(@viking, self)
    end
  end # class LeftWalkingVikingState

  class RightWalkingVikingState < WalkingVikingState
    # viking jde doprava
    def initialize(viking, last_state)
      super(viking)
      velocity_horiz.value = @viking.class::BASE_VELOCITY
    end

    def direction
      "right"
    end

    def move_left
      @viking.state = LeftWalkingVikingState.new(@viking, self)
    end
  end # class RightWalkingVikingState

  class JumpingVikingState < MovingVikingState

    def initialize(viking, last_state)
      super(viking, last_state)
      @velocity_vertic = Velocity.new(-1300, GRAVITY)
      @velocity_horiz = last_state.velocity_vertic
    end

    def to_s
      'jumping'
    end

    def stop
    end

    def stuck
      @viking.state = FallingVikingState.new(@viking, self)
    end

    def direction
      ""
    end
  end # class JumpingVikingState

  class StuckedVikingState < StandingVikingState

    def initialize(viking, last_state)
      super(viking, last_state)
      @last_state = last_state
    end

    def direction
      @last_state.direction
    end

    def to_s
      "stucked_" + direction
    end
  end

  class FallingVikingState < MovingVikingState

    def initialize(viking, last_state)
      super(viking, last_state)
      @last_state = last_state
      @velocity_vertic.value = @viking.class::BASE_VELOCITY
      @velocity_horiz = last_state.velocity_horiz
    end

    def to_s
      "falling_" + @last_state.direction
    end

    def stuck
      @viking.state = StandingVikingState.new(@viking, self)
    end

    def stop
    end
  end # class FallingVikingState

end # module FreeVikings
