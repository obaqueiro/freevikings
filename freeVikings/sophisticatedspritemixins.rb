# sophisticatedspritemixins.rb
# igneus 29.6.2005

=begin
= SophisticatedSpriteMixins
For those who don't know what is a "sophisticated sprite":
Sophisticated Sprite is a (({Sprite})), which is a bit more complicated than 
e.g. a (({Shot})) and needs a special State object to store and work with 
the movement state data.

The mixins described below should ease the work with programming new
Sophisticated Sprites.

They are all encapsulated in a namespace module 
(({SophisticatedSpriteMixins})).

You can use them only for (({Sprite}))s which have a private instance
variable ((|@state|)) with a protocol (public interface) compatible with
that of (({SophisticatedSpriteState})).
=end

module FreeVikings

  module SophisticatedSpriteMixins

=begin
== Walking
=end

    module Walking

=begin
--- Walking#move_left
=end

      def move_left
        @state.move_left
      end

=begin
--- Walking#move_right
=end

      def move_right
        @state.move_right
      end

=begin
--- Walking#stop
=end

      def stop
        @state.stop
      end

=begin
--- Walking#standing?
=end

      def standing?
        @state.standing?
      end

      private

=begin
--- Walking#next_left (private, but useful for implementation of new monsters)
=end

      def next_left
        next_left = @rect.left + (velocity_horiz * @location.ticker.delta)
      end

=begin
--- Walking#velocity_horiz
Computes the x-axis velocity. Uses constant (({BASE_VELOCITY})) which
must be defined in the (({Walking}))-including class.
=end

      def velocity_horiz
        self.class::BASE_VELOCITY * @state.velocity_horiz
      end
    end # module Walking
  end # module SophisticatedSpriteMixins
end # module FreeVikings
