# spritemanager.rb
# igneus 24.1.2005

# Spravce sprajtu.

require 'group.rb'

module FreeVikings

  class SpriteManager < Group

    include PaintableGroup

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

--- SpriteManager#update
It is mainly used in the game loop, where it's called before redisplaying
all the sprites.
=end

    def update
      @members.each { |sprite|
        # If the sprite has got out of the map, we kill it.
        # In the other case the sprite is updated.
        begin
          unless sprite.location.rect_inside?(sprite.rect) then
            sprite.destroy
            @members.delete sprite
          else
            sprite.update
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

    alias_method :sprites_on_rect, :members_on_rect

  end # class SpriteManager
end #module FreeVikings
