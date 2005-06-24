# leggedspritemixins.rb
# igneus 29.6.2005

=begin
= LeggedSpriteMixins
For those who don't know what is a "legged sprite":
Legged Sprite is a Sprite, which is a bit more complicated than e.g. a Shot and
needs a special State object to store and work with the movement state data.
Because most of such objects have leggs, they all got a working name
"Legged Objects" and the base State classe's name is LeggedSpriteState.

The mixins described below should ease the work with programming new
Legged Sprites.

They are all encapsulated in a namespace module ((<LeggedSpriteMixins>)).
=end

module FreeVikings

  module LeggedSpriteMixins

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
  end # module LeggedSpriteMixins
end # module FreeVikings
