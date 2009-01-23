# activeobject.rb
# igneus 16.6.2005

module FreeVikings

  # ActiveObject is a game object which doesn't need to be updated 
  # regularly like Sprite. It's only updated when a key is pressed over it 
  # or if it's stroken by some gun.

  class ActiveObject < Entity

    def initialize(initial_position=[], theme=NullGfxTheme.instance)
      super(initial_position, theme)
      @location = nil # NullLocation.instance
    end

    attr_writer :location

    # Called when the player presses the activation key (S or UP) 
    # with the viking standing at the ActiveObject.

    def activate(who=nil)
    end

    # Called when the player presses the deactivation key (F or DOWN) 
    # with the viking standing at the ActiveObject.

    def deactivate(who=nil)
    end

    # Called when the ActiveObject is stroken by some gun (a sword, an arrow).

    def hurt
    end

    def register_in(location)
      location.add_active_object self
    end
  end # class ActiveObject
end # module FreeVikings
