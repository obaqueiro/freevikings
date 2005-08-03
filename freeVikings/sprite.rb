# sprite.rb
# igneus 19.1.2004

# Tridy sprajtu pro hru FreeVikings

require 'entity.rb'
require 'pausable.rb'
require 'imagebank.rb'

module FreeVikings

  class Sprite < Entity

    include Pausable

=begin
= Sprite
Class Sprite represents an object which needs to periodicaly update it's
internal state. It's sense of life is to be displayed, so it also has some
attributes containing it's position in the location and it's bitmap
representation.
=end

=begin
--- Sprite.new (initial_position = [])
Every ((<Sprite>)) has to have some position. It should be set up when 
the ((<Sprite>)) is created,
but if you don't specify it, it's set to a default value, which is
[0,0] with both width and height 0..
=end

    def initialize(initial_position=[], theme=NullGfxTheme.instance)
      super(initial_position, theme)
      @location = NullLocation.instance
      @energy = 1
    end

=begin
--- Sprite::BASE_VELOCITY
Contains sprite's normal velocity in pixels per second.
=end

    BASE_VELOCITY = 60

=begin
--- Sprite#moving
Returns true if the sprite is moving, nil otherwise.
=end

    attr_reader :moving

=begin
--- Sprite#location
--- Sprite#location=
Some sprites need to ask their environment for some information (e.g. whether
their position is valid, whether they collide with any other sprites etc.).
So when the sprite is placed in the location, the location gives it a reference
to an object (actually self) which has all the information and methods
sprites can call.
=end

    attr_accessor :location

=begin
--- Sprite#top
Returns sprite's top-left corner's distance from the top edge of the map.
=end

    def top
      @rect.top
    end

=begin
--- Sprite#left
Returns sprite's top-left corner's distance from the left edge of the map.
=end

    def left
      @rect.left
    end

=begin
--- Sprite#center
Returns ((<Sprite>))'s center coordinates as an (({Array})) of size 2.
It is used mainly to center the displayed location view according
to the active viking's position.
=end

    def center
      [@rect.left + (@rect.w / 2), @rect.top + (@rect.h / 2)]
    end

=begin
--- Sprite#position
Returns an array of [left, top]. It's only for comfort.
=end

    def position
      [@rect.left, @rect.top]
    end

=begin
--- Sprite#rect
Returns FreeVikings::Rectangle instance saying where the sprite is and how
much place it takes.

--- Sprite#destroy
This method is called when the sprite is killed.
=end

    def destroy
      @energy = 0
      @location.delete_sprite self
    end

=begin
--- Sprite#hurt
Hurt is called when the sprite is damaged, but it isn't sure that it
cannot carry on living.
=end

    def hurt
      @energy -= 1
      destroy if @energy <= 0
    end

=begin
--- Sprite#alive?
Returns true if sprite is still alive, false otherwise.
=end

    def alive?
      @energy > 0
    end

=begin
--- Sprite#image
Returns the sprite's image (RUDL::Surface object).

--- Sprite#stop
Stops sprite's x-axis movement.
=end

    def stop
    end

=begin
--- Sprite#update
Update is periodically called to let the sprite update it's internal state.
=end

    def update
    end

  end # class

end # module
