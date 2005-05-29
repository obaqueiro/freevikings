# oldvikingstate.rb
# igneus 24.1.2005

# Tridy pro stavy vikingu

require 'velocity.rb'

module FreeVikings

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
  class VikingState

    include StateProprieties

    CNTR = CNCTNTR = CONCATENATOR = '_'

    def initialize
      # On the beginning the viking does not move in any axis.
      @horizontal_state = StandingState.new self
      @vertical_state = OnGroundState.new self
      @ability = Ability.new
    end

    attr_writer :horizontal_state
    attr_writer :vertical_state

=begin
--- VikingState#ability=(ability)
Every viking has his special abilities. (Baleog can fight with sword and throw 
arrows, Eric is well-known for his running and jumping and Olaf can use his 
shield.)
These abilities are realized by Ability objects. Ability object also influences
the viking's state and image, so a reference to it must be given to the
VikingState.
=end
    attr_writer :ability

    def moving?
      @vertical_state.moving? or @horizontal_state.moving?
    end

    def direction
      @horizontal_state.direction
    end

    def stop
      @horizontal_state.stop
    end

    def standing?
      velocity_horiz == 0
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

    def rising?
      velocity_vertic < 0
    end

    def descend
      @vertical_state.descend
    end

    def fall
      @vertical_state.fall
    end

    def falling?
      velocity_vertic > 0
    end

    def velocity_horiz
      @horizontal_state.velocity
    end

    def velocity_vertic
      @vertical_state.velocity
    end

    def dump
      "<id:#{object_id} vv:#{velocity_vertic} vh:#{velocity_horiz}>"
    end

=begin
--- VikingState#to_s
Produces a string describing the state. This string has three parts
separated by underscore. The first one describes the vertical state,
the second one the active ability or the horizontal state and
the third one is left or right (the direction, where the viking is looking).
A typical situation:

viking.to_s => 'onground_standing_right'
=end

    def to_s
      @vertical_state.to_s + CNTR + \
      (@ability.to_s ? @ability.to_s : @horizontal_state.to_s) + CNTR + \
      @horizontal_state.direction
    end
  end # class VikingState
end # module FreeVikings

# Vlozime tridy HorizontalState a VerticalState:
require "horizontalstate.rb"
require "verticalstate.rb"
