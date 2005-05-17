# spritemanager.rb
# igneus 24.1.2005

# Spravce sprajtu.

require 'rect.rb'

module FreeVikings

  class SpriteManager

=begin
SpriteManager object keeps an array of all the sprites that should be
regularly redisplayed.
=end

    def initialize(map)
      @sprites = Array.new
      @map = map
    end

    def add(sprite)
      @sprites.push(sprite)
    end

    def delete(sprite)
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
      @sprites.each { |sprite|
	locr = Rectangle.new(*rect_of_location)
        eir = 0
        sr = sprite.rect
        eir += 1 if sr.left > locr.left and sr.left < locr.right
        eir += 1 if sr.right > locr.left and sr.right < locr.right
        eir += 1 if sr.top > locr.top and sr.top < locr.bottom
        eir += 1 if sr.bottom > locr.top and sr.bottom < locr.bottom
        if eir >= 2 then
          relative_left = sprite.left - rect_of_location[0]
          relative_top = sprite.top - rect_of_location[1]
          surface.blit(sprite.image, [relative_left, relative_top])
        end
      }
    end

=begin
--- SpriteManager#update
It is mainly used in the game loop, where it's called before redisplaying
all the sprites.
=end

    def update
      @sprites.each { |entry|
        sprite = entry
        # at je pekne aktualni:
        sprite.update
        # jestli se sprajt dostal mimo mapu, musi byt odstranen
        if sprite.top < 0 or sprite.top > @map.background.h or
            sprite.left < 0 or sprite.left > @map.background.w then
          sprite.destroy
          @sprites.delete sprite
        end
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
	r_rect = Rectangle.new(*rect)
	if r_rect.collides? sprite.rect
	  found.push sprite
	end # if
      end # do
      return found
    end

  end # class SpriteManager
end #module FreeVikings
