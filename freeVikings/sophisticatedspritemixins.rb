# sophisticatedspritemixins.rb
# igneus 29.6.2005

module FreeVikings

  # For those who don't know what is a "sophisticated sprite":
  # Sophisticated Sprite is a (({Sprite})), which is a bit more complicated 
  # than 
  # e.g. a Shot and needs a special State object to store and work with 
  # the movement state data.
  #
  # The mixins described below should ease the work with programming new
  # Sophisticated Sprites.
  #
  # They are all encapsulated in a namespace module 
  # (({SophisticatedSpriteMixins})).
  #
  # You can use them only for (({Sprite}))s which have a private instance
  # variable ((|@state|)) with a protocol (public interface) compatible with
  # that of (({SophisticatedSpriteState})).
  module SophisticatedSpriteMixins

    # Some useful private methods (computing next position of the sprite,
    # his velocity etc.)
    # Is by default included in some other mixins, so you don't need 
    # to include this by hand.
    module Basic
      
      private

      def next_left
        (@rect.left + (velocity_horiz * @location.ticker.delta)).to_i
      end

      def next_top
        (@rect.top + (velocity_vertic * @location.ticker.delta)).to_i
      end

      def next_position
        Rectangle.new next_left, next_top, @rect.w, @rect.h
      end

      # x-axis velocity of the sprite.
      def velocity_horiz
        @state.velocity_horiz * self.class::BASE_VELOCITY * FreeVikings::OPTIONS['velocity_unit']
      end

      # y-axis velocity of the sprite
      def velocity_vertic
        @state.velocity_vertic * self.class::BASE_VELOCITY * FreeVikings::OPTIONS['velocity_unit']
      end
    end # module Basic

    # Methods useful for walking creatures (see e.g. Viking or Bear)
    module Walking

      include Basic

      def move_left
        @state.move_left
      end

      def move_right
        @state.move_right
      end

      def stop
        @state.stop
      end

      def standing?
        @state.standing?
      end
    end # module Walking
  end # module SophisticatedSpriteMixins
end # module FreeVikings
