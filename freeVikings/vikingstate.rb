# oldvikingstate.rb
# igneus 24.1.2005

# Tridy pro stavy vikingu

require 'velocity.rb'

module FreeVikings

  # Module Future protects the development version of the VikingState class
  # from collisions with the old (dirty) one.

  module Future

    GRAVITY = 1

    module StateProprieties
      # StateProprieties is a mixin. It contains all the proprieties
      # common for all the (both vertical and horizontal) State objects.

      def moving?
      end

      def to_s
        ""
      end
    end

    class VikingState
      # A VikingState object carries out all the state changes.
      # Encapsulates information about vikings's velocity and direction.

      include StateProprieties

      def initialize
        @horizontal_state = StandingState.new self
        @vertical_state = VerticalState.new
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
      end
      
      def stuck
        nil
      end

      def move_left
        @horizontal_state.move_left
      end

      def move_right
        @horizontal_state.move_right
      end

      def move_up
        nil
      end

      def move_down
        nil
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
    end # class VikingState

  end # module Future

end # module FreeVikings

# Vlozime tridy HorizontalState a VerticalState:
require "horizontalstate.rb"
require "verticalstate.rb"
