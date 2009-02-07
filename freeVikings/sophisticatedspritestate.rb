# sophisticatedspritestate.rb
# igneus 28.6.2005

require 'stateproprieties.rb'
require 'verticalstate.rb'
require 'horizontalstate.rb'

module FreeVikings

  # For a long time only the vikings needed to have a sophisticated
  # State object to keep information about their movement. The other sprites
  # haven't needed such a complicated and powerful mechanism. They haven't
  # been moving (like a Duck) or have been moving with a very simple
  # pattern (Shot or Robot). But simple enemies make no fun.
  # So I decided to make VikingState more general and create some more
  # complicated creatures such as a Bear.
  #
  # SophisticatedSpriteState makes it possible for the Sprite to walk, 
  # jump and fall.

  class SophisticatedSpriteState

    include StateProprieties

    CNTR = CNCTNTR = CONCATENATOR = '_'

    def initialize
      # On the beginning the sprite does not move in any axis.
      @horizontal_state = StandingState.new self
      @vertical_state = OnGroundState.new self
    end

    attr_accessor :horizontal_state
    attr_accessor :vertical_state

    def moving?
      @vertical_state.moving? or @horizontal_state.moving?
    end

    def moving_horizontally?
      @horizontal_state.moving?
    end

    def moving_vertically?
      @vertical_state.moving?
    end

    def on_ground?
      @vertical_state.is_a? OnGroundState
    end

    def climbing?
      @vertical_state.climbing?
    end

    def stop
      @horizontal_state.stop
    end

    def standing?
      velocity_horiz == 0
    end
      
    def move
      @horizontal_state.move
    end

    def rise
      @vertical_state.rise
    end

    def rising?
      @vertical_state.is_a? RisingState
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

    def knockout
      @horizontal_state.knockout
    end

    def knocked_out?
      @horizontal_state.kind_of? KnockedOutState
    end

    def unknockout
      @horizontal_state.unknockout
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
  end # class SophisticatedSpriteState
end # module FreeVikings
