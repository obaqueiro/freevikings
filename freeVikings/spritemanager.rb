# spritemanager.rb
# igneus 24.1.2005

# Spravce sprajtu.

require 'movevalidator'

module FreeVikings

  class SpriteManager

=begin
SpriteManager object keeps an array of all the sprites that should be
regularly redisplayed.
The Suite design pattern is used, so it does not really keep a list of
sprites, but a list of objects, which define a method each_displayable
yielding all the sprites it wants to be displayed (see files team.rb and
sprite.rb for implementation of this method).
=end

    include MoveValidator

    def initialize(map)
      @sprites = Array.new
      @map = map
    end

    def add(sprite)
      @sprites.push(sprite)
      sprite.each_displayable { |d|
	d.move_validator = self if d.respond_to? :move_validator=
      }
    end

=begin
--- SpriteManager#paint( surface, rect_of_location )
This method takes a RUDL::Surface object (surface) and paints onto it all the
sprites which can be found in a rect defined by an four-entry-array
rect_of_location. The rect definition contains a left coordinate of the top
left corner, top coordinate of the top left corner, rect's width and it's
height. The coordinates are relative to the map loaded.
=end

    def paint(surface, rect_of_location)
      @sprites.each { |entry|
	entry.each_displayable { |sprite|
	  if sprite.top > rect_of_location[1] and
	      sprite.top < rect_of_location[3] and
	      sprite.left > rect_of_location[0] and
	      sprite.left < rect_of_location[2] then
	    relative_left = sprite.left - rect_of_location[0]
	    relative_top = sprite.top - rect_of_location[1]
	    surface.blit(sprite.image, [relative_left, relative_top])
	  end
	}
      }
    end

=begin
--- SpriteManager#update
It updates the state of manager and calls update on every sprite (don't forget
we've got each_displayable methods).
It is mainly used in the game loop, where it's called before redisplaying
all the sprites.
=end

    def update
      @sprites.each { |entry|
	entry.each_displayable { |sprite|
	  # at je pekne aktualni:
	  sprite.update
	  # jestli se sprajt dostal mimo mapu, musi byt odstranen
	  if sprite.top < 0 or sprite.top > @map.background.h or
	      sprite.left < 0 or sprite.left > @map.background.w then
	    sprite.destroy
	    @sprites.delete sprite
	  end
	}
      }
    end

=begin
--- SpriteManager#is_position_valid?( sprite, position )
Returns true or nil. True indicates that the rect computed from the sprite's
image's size and the position (array of two Integers - the first keeps the
distance of sprite's top left corner from the left edge of the map) is free.
What does it mean? That the rect doesn't collide with any map's solid blocks.
Collisions with the other sprites must be controlled separately.
=end

    def is_position_valid?(sprite, position)
      begin
	colliding_blocks = @map.blocks_on_square([position[0], position[1], sprite.image.w, sprite.image.h])
      rescue RuntimeError
	return nil
      end

      colliding_blocks.each do |block|
	# je blok pevny (solid)? Pevne bloky nejsou pruchozi.
	return nil if block.solid == true
      end
      # az dosud nebyl nalezen pevny blok, posice je volna
      return true
    end

  end
end #module FreeVikings
