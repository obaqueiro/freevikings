# sophisticatedspritemixins.rb
# igneus 29.6.2005

=begin
= SophisticatedSpriteMixins
For those who don't know what is a "sophisticated sprite":
Sophisticated Sprite is a Sprite, which is a bit more complicated than 
e.g. a Shot and needs a special State object to store and work with 
the movement state data.

The mixins described below should ease the work with programming new
Sophisticated Sprites.

They are all encapsulated in a namespace module ((<SophisticatedSpriteMixins>)).
=end

module FreeVikings

  module SophisticatedSpriteMixins

    module Walking

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

      private

      def next_left
        next_left = @rect.left + (velocity_horiz * @location.ticker.delta)
      end
    end # module Walking
  end # module SophisticatedSpriteMixins
end # module FreeVikings
