# spritemanager.rb
# igneus 24.1.2005

# Spravce sprajtu.

require 'group.rb'
require 'ext/Rectangle'
#require 'rect.rb'

module FreeVikings

  Rectangle = FreeVikings::Extensions::Rectangle::Rectangle

  class SpriteManager < Group

=begin
= SpriteManager
SpriteManager object is a ((<Group>)) of all the sprites that should be
regularly redisplayed. It has all the methods inherited from ((<Group>)),
to learn more about them, see the superclasse's documentation.

--- SpriteManager.new
--- SpriteManager#add(object)
--- SpriteManager#delete(member)
--- SpriteManager#include?(object)

--- SpriteManager#paint( surface, rect_of_location )
This method takes a RUDL::Surface object (surface) and paints onto it all the
sprites which can be found in a rect defined by a Rectangle
rect_of_location. The rect definition contains a left coordinate of the top
left corner, top coordinate of the top left corner, rect's width and it's
height. The coordinates are relative to the map loaded.
=end

    def paint(surface, rect_of_location)
      locr = rect_of_location
      raise(ArgumentError, "Wrong type of argument: #{locr.class} should be: Rectangle") unless locr.kind_of? Rectangle
      @members.each { |sprite|
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
      @members.each { |sprite|
        # at je pekne aktualni:
        sprite.update
        # jestli se sprajt dostal mimo mapu, musi byt odstranen
        begin
          unless sprite.location.rect_inside?(sprite.rect) then
            sprite.destroy
            @members.delete sprite
          end
        rescue NullLocation::NullLocationException
          Log4r::Logger['freeVikings log'].fatal "Sprite #{sprite} doesn't have it's 'location' attribute set to a valid Location class."
          raise
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
      @members.each do |sprite|
	if rect.collides? sprite.rect
	  found.push sprite
	end # if
      end # do
      return found
    end

  end # class SpriteManager
end #module FreeVikings
