# horizontalstate.rb
# igneus 23.5.2005

# HorizontalState (abstraktni trida) a jeji podtridy.
# Ty se staraji o stavove informace vikinga co se tyce pohybu
# v horizontalnim smeru.

=begin
= HorizontalState
The new solution of VikingState uses an object VikingState as a wrapper
of some other objects containing different state information.
(About movement in the x and y axis, usage of special abilities etc.)
VikingState just dispatches the calls and has only few to do self.
HorizontalState is an abstract class. Objects of it's subclasses contain
data about the x-axis movement. E.g. LeftWalkingState describes an internal
state of a viking going to the left side.
=end

module FreeVikings

  class HorizontalState

    include Future::StateProprieties

=begin
--- HorizontalState.new( wrapper, direction=nil )
Creates a new HorizontalState object. Argument wrapper is the VikingState
object which will use this new HorizontalState.
Direction is a String ("right" or "left"). Most of the HorizontalState
subclasses ignore this argument, only StandingState uses it.
Maybe one day this argument will be removed and two classes -
LeftStandingState and RightStandingState - added.
=end

    def initialize(wrapper, direction='right')
      @wrapper = wrapper
      @direction = direction
    end

    attr_reader :direction

    def move_left
      @wrapper.horizontal_state = LeftWalkingState.new @wrapper, @direction
    end

    def move_right
      @wrapper.horizontal_state = RightWalkingState.new @wrapper, @direction
    end

    def stop
      @wrapper.horizontal_state = StandingState.new @wrapper, @direction
    end

    def velocity
      @velocity.value
    end
  end # class HorizontalState

  class LeftWalkingState < HorizontalState

    include Future::MovingStateProprieties

    def initialize(wrapper, direction='right')
      super(wrapper, direction)
      @velocity = Velocity.new(-VELOCITY_BASE)
      @direction = "left"
    end
  end # class LeftWalkingState

  class RightWalkingState < HorizontalState

    include Future::MovingStateProprieties
    
    def initialize(wrapper, direction='right')
      super(wrapper, direction)
      @velocity = Velocity.new(VELOCITY_BASE)
      @direction = "right"
    end
  end # class RightWalkingState

  class StandingState < HorizontalState

    include Future::NotMovingStateProprieties

    def initialize(wrapper, direction='right')
      super(wrapper, direction)
      @velocity = Velocity.new 0
    end

    def to_s
      'standing'
    end
  end # class StandingState

end
