# stateproprieties.rb
# igneus 28.6.2005

# Little pieces around the LeggedSpriteState

module FreeVikings

  module StateProprieties
    # StateProprieties is a mixin. It contains all the proprieties
    # common for all the (both vertical and horizontal) State objects.

    VELOCITY_BASE = 1
  end

  module MovingState
    def moving?
      true
    end
  end

  module NotMovingState

    def initialize(wrapper)
      super(wrapper)
      @velocity = 0
    end

    def moving?
      false
    end
  end
end # module FreeVikings
