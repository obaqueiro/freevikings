# stateproprieties.rb
# igneus 28.6.2005

# Little pieces around the LeggedSpriteState

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
end # module FreeVikings
