# vikingstate.rb
# igneus 24.1.2005

require 'sophisticatedspritestate.rb'

module FreeVikings

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

  class VikingState < SophisticatedSpriteState

    def initialize
      super()
      @ability = Ability.new
    end

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
