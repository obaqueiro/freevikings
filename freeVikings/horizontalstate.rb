# horizontalstate.rb
# igneus 23.5.2005

# HorizontalState (abstraktni trida) a jeji podtridy.
# Ty se staraji o stavove informace vikinga co se tyce pohybu
# v horizontalnim smeru.

require 'stateproprieties.rb'

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

    include StateProprieties

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
    attr_reader :velocity

    def move_left
      @wrapper.horizontal_state = LeftWalkingState.new @wrapper, @direction
    end

    def move_right
      @wrapper.horizontal_state = RightWalkingState.new @wrapper, @direction
    end

    def stop
      @wrapper.horizontal_state = StandingState.new @wrapper, @direction
    end

    def knockout
      @wrapper.horizontal_state = KnockedOutState.new @wrapper, @direction
    end

    def unknockout
    end
  end # class HorizontalState

  class LeftWalkingState < HorizontalState

    include MovingStateProprieties

    def initialize(wrapper, direction='right')
      super(wrapper, direction)
      @velocity = -VELOCITY_BASE
      @direction = "left"
    end
  end # class LeftWalkingState

  class RightWalkingState < HorizontalState

    include MovingStateProprieties
    
    def initialize(wrapper, direction='right')
      super(wrapper, direction)
      @velocity = VELOCITY_BASE
      @direction = "right"
    end
  end # class RightWalkingState

  class StandingState < HorizontalState

    include NotMovingStateProprieties

    def initialize(wrapper, direction='right')
      super(wrapper, direction)
      @velocity = 0
    end

    STRING_VALUE = 'standing'

    def to_s
      STRING_VALUE
    end
  end # class StandingState

  class KnockedOutState < HorizontalState

    include NotMovingStateProprieties

    def initialize(wrapper, direction='right')
      super(wrapper, direction)
      @velocity = 0
    end

    STRING_VALUE = 'knocked-out'

    def to_s
      STRING_VALUE
    end

    def move_left
    end

    def move_right
    end

    def stop
    end

    def unknockout
      @wrapper.horizontal_state = StandingState.new @wrapper, @direction
    end
  end # class KnockedOutState

end
