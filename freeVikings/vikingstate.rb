# oldvikingstate.rb
# igneus 24.1.2005

# Tridy pro stavy vikingu

require 'velocity.rb'

module FreeVikings

  # Module Future protects the development version of the VikingState class
  # from collisions with the old (dirty) one.

  module Future

    GRAVITY = 1

    module State
      # State is a mixin. It contains methods which all the state
      # objects (both vertical and horizontal) have.

      def moving?
      end

      def to_s
        ""
      end
    end

    class VikingState
      # A VikingState object carries out all the state changes.
      # Encapsulates information about vikings's velocity and direction.

      include State

      attr_reader :velocity_horiz
      attr_reader :velocity_vertic

      def initialize
      end

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
        "<id:#{object_id} vv:#{velocity_vertic.value} vh:#{velocity_horiz.value}>"
      end
    end # class VikingState

    class VerticalState
    end

    class VerticalState
    end

  end # module Future

end # module FreeVikings
