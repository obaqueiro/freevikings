# verticalstate.rb
# igneus 23.5.2005

# Abstraktni trida VerticalState a jeji podtridy.
# Soucast noveho pojeti myslenky VikingState.

=begin
= VerticalState
VerticalState subclasses' objects are used in VikingState to hold
the y-axis movement state information.
=end

module FreeVikings

  class VerticalState

    include StateProprieties

    def initialize(wrapper)
      @wrapper = wrapper
    end

    def velocity
      @velocity.value
    end

    def rise
      @wrapper.vertical_state = RisingState.new @wrapper
    end

    def fall
      @wrapper.vertical_state = FallingState.new @wrapper
    end

    def descend # dosednuti, zastaveni padu.
      @wrapper.vertical_state = OnGroundState.new @wrapper
    end
  end # class VerticalState


  class OnGroundState < VerticalState
    include NotMovingStateProprieties

    def initialize(wrapper)
      super wrapper
      @velocity = Velocity.new 0
    end

    def to_s
      'onground'
    end
  end # class OnGroundState

  class FallingState < VerticalState
    include MovingStateProprieties

    def initialize(wrapper)
      super wrapper
      @velocity = Velocity.new VELOCITY_BASE
    end

    def to_s
      'falling'
    end
  end # class FallingState

  class RisingState < VerticalState
    include MovingStateProprieties

    def initialize(wrapper)
      super wrapper
      @velocity = Velocity.new( - VELOCITY_BASE)
    end

    def to_s
      'rising'
    end
  end # class RisingState
end # module FreeVikings
