# vikingstate.rb
# igneus 24.1.2005

# Tridy pro stavy vikingu

require 'velocity.rb'

module FreeVikings

  class VikingState
    # Supertrida pro tridy Stavu vikinga

    attr_reader :velocity_horiz
    attr_reader :velocity_vertic

    def initialize(viking)
      @viking = viking
      @velocity_horiz = Velocity.new
      @velocity_vertic = Velocity.new
    end

    def to_s
      ""
    end

    def moving?
      nil
    end

    def stop
      nil
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
  end # class VikingState

  class StandingVikingState < VikingState
    def to_s
      "standing"
    end

    def move_left
      @viking.state = LeftWalkingVikingState.new(@viking)
    end

    def move_right
      @viking.state = RightWalkingVikingState.new(@viking)
    end
  end # class StandingVikingState

  class MovingVikingState < VikingState
    def moving?
      true
    end
  end # class MovingVikingState

  class WalkingVikingState < MovingVikingState
    # Supertrida pro tridy chuze, padani a splhani
    def stop
      @viking.state = StandingVikingState.new(@viking)
    end
  end # class MovingVikingState

  class LeftWalkingVikingState < WalkingVikingState
    # viking jde doleva
    def initialize(viking)
      super(viking)
      @velocity_horiz.value = - (@viking.class::BASE_VELOCITY)
    end

    def to_s
      "moving_left"
    end

    def move_right
      @viking.state = RightWalkingVikingState.new(@viking)
    end
  end # class LeftWalkingVikingState

  class RightWalkingVikingState < WalkingVikingState
    # viking jde doprava
    def initialize(viking)
      super(viking)
      velocity_horiz.value = @viking.class::BASE_VELOCITY
    end

    def to_s
      "moving_right"
    end

    def move_left
      @viking.state = LeftWalkingVikingState.new(@viking)
    end
  end # class RightWalkingVikingState

  class FallingVikingState < MovingVikingState
  end # class FallingVikingState
end # module FreeVikings
