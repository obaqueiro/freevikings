# vikingstate.rb
# igneus 24.1.2005

require 'sophisticatedspritestate.rb'

module FreeVikings

  # Instance of VikingState describes an internal state of specific Viking 
  # (or any other Sprite) object. (Word 'state' means the movement state 
  # here.) 
  # It provides methods to change the state and to check the some important 
  # state 
  # values (direction of vertical and horizontal movement, x and y axis 
  # velocity,
  # symbolic name  of the image which represents the viking in his topical 
  # state).
  #
  # Internally VikingState is implemented as two objects. One is an instance 
  # of HorizontalState's subclass and has the y-axis movement data.
  # The X-axis movement data are covered in an instance of VerticalState's
  # subclass.

  class VikingState < SophisticatedSpriteState

    def initialize
      super()
      @ability = Ability.new
    end

    # Every viking has his special abilities. (Baleog can fight with sword and 
    # throw 
    # arrows, Eric is well-known for his running and jumping and Olaf can 
    # use his shield.)
    # These abilities are realized by Ability objects. Ability object also 
    # influences
    # the viking's state and image, so a reference to it must be given to the
    # VikingState.

    attr_accessor :ability

  end # class VikingState
end # module FreeVikings

# require classes HorizontalState a VerticalState:
require "horizontalstate.rb"
require "verticalstate.rb"
