# horizontalstate.rb
# igneus 23.5.2005

require 'stateproprieties.rb'

module FreeVikings

  # The new solution of VikingState uses an object VikingState as a wrapper
  # of some other objects containing different state information.
  # (About movement in the x and y axis, usage of special abilities etc.)
  # VikingState just dispatches the calls and has only few to do self.
  # HorizontalState is an abstract class. Objects of it's subclasses contain
  # data about the x-axis movement. E.g. LeftWalkingState describes an internal
  # state of a viking going to the left side.

  class HorizontalState

    include StateProprieties

    # Creates a new HorizontalState object. Argument wrapper is the VikingState
    # object which will use this new HorizontalState.
    # Direction is a String ("right" or "left"). Most of the HorizontalState
    # subclasses ignore this argument, only StandingState uses it.
    # Maybe one day this argument will be removed and two classes -
    # LeftStandingState and RightStandingState - added.

    def initialize(wrapper)
      @wrapper = wrapper
    end

    attr_reader :velocity

    def move
      @wrapper.horizontal_state = WalkingState.new(@wrapper)
    end

    def stop
      @wrapper.horizontal_state = StandingState.new @wrapper
    end

    def knockout
      @wrapper.horizontal_state = KnockedOutState.new @wrapper
    end

    def unknockout
    end

    def to_s
      self.class::STRING_VALUE
    end
  end # class HorizontalState

  class WalkingState < HorizontalState

    include MovingState

    STRING_VALUE = 'moving'

    def initialize(wrapper)
      super(wrapper)
      @velocity = VELOCITY_BASE
    end
  end # class LeftWalkingState

  class StandingState < HorizontalState

    include NotMovingState

    STRING_VALUE = 'standing'
  end # class StandingState

  class KnockedOutState < HorizontalState

    include NotMovingState

    STRING_VALUE = 'knocked-out'

    def move_left
    end

    def move_right
    end

    def stop
    end

    def unknockout
      @wrapper.horizontal_state = StandingState.new @wrapper
    end
  end # class KnockedOutState

  class SwordFightingState < HorizontalState

    include NotMovingState

    STRING_VALUE = 'sword-fighting'

    def move
    end

    def stop
    end
  end

  class BowStretchingState < HorizontalState

    include NotMovingState

    STRING_VALUE = 'bow-stretching'

    def move
    end

    def stop
    end
  end

  # This is state connected with Eric's special ability - magical helmet
  # which can kill some monsters and destroy walls

  class BullHeadState < HorizontalState

    include MovingState

    STRING_VALUE = 'bullhead'

    def initialize(wrapper)
      super(wrapper)
      @velocity = VELOCITY_BASE * 2
    end
  end

  class PullingState < HorizontalState

    include MovingState

    STRING_VALUE = 'pulling'

    def initialize(wrapper)
      super(wrapper)
      @velocity = VELOCITY_BASE * 0.6
    end
  end

end
