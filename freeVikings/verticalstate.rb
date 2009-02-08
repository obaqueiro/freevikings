# verticalstate.rb
# igneus 23.5.2005

require 'stateproprieties.rb'

module FreeVikings

  # VerticalState subclasses' objects are used in VikingState to hold
  # the y-axis movement state information.

  class VerticalState

    include StateProprieties

    def initialize(wrapper)
      @wrapper = wrapper
    end

    attr_reader :velocity

    def rise
      @wrapper.vertical_state = RisingState.new @wrapper
    end

    def fall
      @wrapper.vertical_state = FallingState.new @wrapper
    end

    def descend # dosednuti, zastaveni padu.
      @wrapper.vertical_state = OnGroundState.new @wrapper
    end

    def to_s
      self.class::STRING_VALUE
    end

    def climbing?
      false
    end
  end # class VerticalState


  class OnGroundState < VerticalState
    include NotMovingState

    def initialize(wrapper)
      super wrapper
      @velocity = 0
    end

    STRING_VALUE = 'onground'
  end # class OnGroundState

  class FallingState < VerticalState
    include MovingState

    def initialize(wrapper)
      super wrapper
      @velocity = VELOCITY_BASE
    end

    STRING_VALUE = 'falling'    
  end # class FallingState

  class RisingState < VerticalState
    include MovingState

    def initialize(wrapper)
      super wrapper
      @velocity = - VELOCITY_BASE
    end

    STRING_VALUE = 'rising'
  end # class RisingState

  class ClimbingUpState < VerticalState
    include MovingState

    def initialize(wrapper)
      super wrapper
      @velocity = - VELOCITY_BASE
    end

    STRING_VALUE = 'climbingUp'

    def climbing?
      true
    end
  end

  class ClimbingDownState < VerticalState
    include MovingState

    def initialize(wrapper)
      super wrapper
      @velocity = VELOCITY_BASE
    end

    STRING_VALUE = 'climbingDown'

    def climbing?
      true
    end
  end

  class ClimbingHavingRestState < VerticalState
    include NotMovingState

    def initialize(wrapper)
      super wrapper
      @velocity = 0
    end

    STRING_VALUE = 'climbingRest'

    def climbing?
      true
    end
  end

end # module FreeVikings
