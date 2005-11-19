# activeobject.rb
# igneus 16.6.2005

=begin
= NAME
ActiveObject

= DESCRIPTION
(({ActiveObject})) is a game object which doesn't need to be updated 
regularly like (({Sprite})). It's only updated when a key is pressed over it 
or if it's stroken by some gun.

= Superclass
Entity
=end

require 'entity.rb'

module FreeVikings

  class ActiveObject < Entity

    def initialize(initial_position=[], theme=NullGfxTheme.instance)
      super(initial_position, theme)
    end

=begin
= Instance methods

--- ActiveObject#activate
Called when the player presses the activation key (S or UP) with the viking 
standing at the (({ActiveObject})).
=end

    def activate
    end

=begin
--- ActiveObject#deactivate
Called when the player presses the deactivation key (F or DOWN) 
with the viking standing at the (({ActiveObject})).
=end

    def deactivate
    end

=begin
--- ActiveObject#hurt
Called when the (({ActiveObject})) is stroken by some gun (a sword, an arrow).
=end

    def hurt
    end

    def register_in(location)
      @location.add_active_object self
    end
  end # class ActiveObject
end # module FreeVikings
