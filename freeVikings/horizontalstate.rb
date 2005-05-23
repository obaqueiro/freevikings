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
data about the x-axis movement.
=end

module FreeVikings

  class HorizontalState

    VELOCITY_BASE = 1

    def initialize(wrapper, direction=nil)
      @wrapper = wrapper
      @direction = direction or @direction = "right"
    end

    attr_reader :direction

    def move_left
      @wrapper.horizontal_state = LeftWalkingState.new @wrapper, @direction
    end

    def move_right
      @wrapper.horizontal_state = RightWalkingState.new @wrapper, @direction
    end

    def velocity
      @velocity.value
    end
  end # class HorizontalState

  class LeftWalkingState < HorizontalState

    def initialize(wrapper, direction=nil)
      super(wrapper, direction)
      @velocity = Velocity.new(-VELOCITY_BASE)
      @direction = "left"
    end
  end # class LeftWalkingState

  class RightWalkingState < HorizontalState
    
    def initialize(wrapper, direction=nil)
      super(wrapper, direction)
      @velocity = Velocity.new(VELOCITY_BASE)
      @direction = "right"
    end
  end # class RightWalkingState

  class StandingState < HorizontalState

    def initialize(wrapper, direction=nil)
      super(wrapper, direction)
      @velocity = Velocity.new 0
    end
  end # class StandingState

end
