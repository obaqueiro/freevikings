# oldvikingstate.rb
# igneus 24.1.2005

# Tridy pro stavy vikingu

require 'velocity.rb'

=begin
= VikingState
Instance of VikingState describes an internal state of specific Viking 
(or any other Sprite) object. (Word 'state' means the movement state here.) 
It provides methods to change the state and to check the some important state 
values (direction of vertical and horizontal movement, x and y axis velocity,
symbolic name  of the image which represents the viking in his topical state).

Internally VikingState is implemented as two objects. One is an instance 
of HorizontalState's subclass and has the y-axis movement data.
The X-axis movement data are covered in an instance of VerticalState's
subclass.
=end

module FreeVikings

  # Module Future protects the development version of the VikingState class
  # from collisions with the old (dirty) one.

  module Future

    module StateProprieties
      # StateProprieties is a mixin. It contains all the proprieties
      # common for all the (both vertical and horizontal) State objects.

      VELOCITY_BASE = 1
    end

    module MovingStateProprieties
      def moving?
        true
      end

      def to_s
        'moving'
      end
    end

    module NotMovingStateProprieties
      def moving?
        false
      end
    end

    class VikingState
      # A VikingState object carries out all the state changes.
      # Encapsulates information about vikings's velocity and direction.

      include StateProprieties

      CNTR = CNCTNTR = CONCATENATOR = '_'

      def initialize
        # On the beginning the viking does not move in any axis.
        @horizontal_state = StandingState.new self
        @vertical_state = OnGroundState.new self
      end

      attr_writer :horizontal_state
      attr_writer :vertical_state

      def moving?
        @vertical_state.moving? or @horizontal_state.moving?
      end

      def direction
        @horizontal_state.direction
      end

      def stop
        @horizontal_state.stop
      end
      
      def move_left
        @horizontal_state.move_left
      end

      def move_right
        @horizontal_state.move_right
      end

      def rise
        @vertical_state.rise
      end

      def descend
        @vertical_state.descend
      end

      def fall
        @vertical_state.fall
      end

      def velocity_horiz
        @horizontal_state.velocity
      end

      def velocity_vertic
        @vertical_state.velocity
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
        "<id:#{object_id} vv:#{velocity_vertic.value} vh:#{velocity_horiz.value}>"
      end

      def to_s
        @vertical_state.to_s + CNTR + @horizontal_state.to_s + CNTR + @horizontal_state.direction
      end
    end # class VikingState

  end # module Future

end # module FreeVikings

# Vlozime tridy HorizontalState a VerticalState:
require "horizontalstate.rb"
require "verticalstate.rb"
