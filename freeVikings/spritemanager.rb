# spritemanager.rb
# igneus 24.1.2005

# Spravce sprajtu.

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

    def initialize(map)
      @sprites = Array.new
      @map = map
    end

    def add(sprite)
      @sprites.push(sprite)
    end

    def delete(sprite)
      sprite.destroy
      @sprites.delete(sprite)
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
--- SpriteManager#sprites_on_rect(rect)
It finds and in an Array returns all the sprites which can be found in the
rectangle defined by the array rect given as parameter.
If no sprite is found, it returns an empty array.
=end

    def sprites_on_rect(rect)
      found = Array.new
      @sprites.each do |sprite|
	sprite_right = sprite.left + sprite.image.w
	sprite_bottom = sprite.top + sprite.image.h
	if ( (sprite.left > rect[0] and sprite.left < (rect[0] + rect[2])) and 
	    (sprite.top > rect[1] and sprite.top < (rect[1] + rect[3])) ) or
	    ( (sprite_right > rect[0] and sprite_right < (rect[0] + rect[2])) and
	     (sprite.top > rect[1] and sprite.top < (rect[1] + rect[3])) ) then
	  found.push sprite
	end # if
      end # do
      return found
    end

  end # class SpriteManager
end #module FreeVikings
