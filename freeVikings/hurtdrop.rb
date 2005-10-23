# hurtdrop.rb
# igneus 23.10.2005

=begin
= NAME
HurtDrop

= DESCRIPTION
This is the blue stain which appears when you hurt some monster
or when some viking is hurt.

It is normally registered as a sprite, but it's a subclass of (({Entity}))
because it is used from within (({Sprite})).

= Superclass
Entity
=end

require 'sprite.rb'
require 'timelock.rb'

module FreeVikings

  class HurtDrop < Entity

    WIDTH = HEIGHT = 25

    def initialize(position)
      super(position)

      @timelock = TimeLock.new(0.5)
      @location = nil
    end

    attr_accessor :location

    def update
      destroy if @timelock.free?
    end

    def destroy
      @location.delete_sprite self
    end

    def init_images
      @image = Image.load 'hurt_drop.tga'
    end
  end # class HurtDrop
end # module FreeVikings
