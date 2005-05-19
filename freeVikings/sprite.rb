# freeVikings - the "Lost Vikings" clone
# Copyright (C) 2005 Jakub "igneus" Pavlik

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# igneus 19.1.2004

# Tridy sprajtu pro hru FreeVikings

require 'velocity.rb'
require 'imagebank.rb'
require 'rect.rb'

module FreeVikings

  class Sprite

=begin
=FreeVikings::Sprite class
Class Sprite represents an object which has to periodicaly update it's
internal state. It's sense of life is to be displayed, so it also has some
attributes containing it's position in the location and it's bitmap
representation.
=end

=begin
--- Sprite.new (initial_position = [])
Every sprite has to have some position. It should be set up when it's created,
but if you don't specify it, it's set to a default value.
=end

    def initialize(initial_position=[])
      @image = Image.new('nobody.tga')

      unless initial_position.empty?
	@position = initial_position.dup
      else
	@position = [70,60]
      end
    end

=begin
--- Sprite::BASE_VELOCITY
It's a constant mostly for internal use. It contains sprite's normal velocity
in pixels per second.
=end

    BASE_VELOCITY = 60

=begin
--- Sprite#moving
Returns true if the sprite is moving, else returns nil.
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
      @position[1]
    end

=begin
--- Sprite#left
Returns sprite's top-left corner's distance from the left edge of the map.
=end

    def left
      @position[0]
    end

=begin
--- Sprite#position
Returns an array of [left, top]. It's only for comfort.
=end

    def position
      [left, top]
    end

=begin
--- Sprite#rect
Returns FreeVikings::Rectangle instance saying where the sprite is and how
much place it takes.
=end

    def rect
      Rectangle.new *[left, top, image.w, image.h]
    end

=begin
--- Sprite#destroy
This method is called when the sprite is killed.
=end

    def destroy
      @location.delete_sprite self
    end

=begin
--- Sprite#hurt
Hurt is called when the sprite is damaged, but it isn't sure that it
cannot carry on living.
=end

    def hurt
      destroy # jednoduche organismy zraneni nepreziji
    end

=begin
--- Sprite#image
Returns RUDL::Surface object used to display sprite on the display.
=end

    def image
      @image.image
    end

=begin
--- Sprite#stop
It's called when the sprite is moving where or how it should not be.
=end

    def stop
    end

=begin
--- Sprite#update
It's periodically called to let the sprite update it's internal state.
=end

    def update
    end

  end # class

end # module
