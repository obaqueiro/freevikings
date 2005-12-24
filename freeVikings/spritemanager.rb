# spritemanager.rb
# igneus 24.1.2005

# Spravce sprajtu.

require 'group.rb'
require 'selectivegroup.rb'
require 'hero.rb'
require 'forwardable'

module FreeVikings

  class SpriteManager < Group

    extend Forwardable

=begin
= NAME
SpriteManager

= DESCRIPTION
(({SpriteManager})) instance is a ((<Group>)) of all the entities which 
should be regularly redisplayed. It has all the methods inherited 
from ((<Group>)),
to learn more about them, see the superclasse's documentation.

= Superclass
Group

= Instance methods

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

--- SpriteManager#members_on_rect(rect)
=end

    def initialize
      super()

      @heroes = SelectiveGroup.new(Proc.new {|object|
                                     object.kind_of? Hero
                                   })
      @monsters = SelectiveGroup.new(Proc.new {|object|
                                       object.kind_of? Monster
                                     })

      @nested_groups = [@heroes, @monsters]
    end

=begin
--- SpriteManager#heroes_on_rect(rect)
--- SpriteManagerrect(rect)
Return an (({Array})) of ((|rect|)) colliding (({Hero}))es or
(({Monster}))s respectively.
Possibly quicker than ((<SpriteManager#members_on_rect>)).
=end

    def_delegator :@heroes, :members_on_rect, :heroes_on_rect
    def_delegator :@monsters, :members_on_rect, :monsters_on_rect

    def add(object)
      super(object)

      @nested_groups.each do |g|
        g.add(object) if g.acceptable?(object)
      end
    end

    def delete(member)
      super(member)

      @nested_groups.each do |g|
        g.delete(member)
      end
    end

    def update
      @members.each { |sprite|
        # If the sprite has got out of the map, we kill it.
        # In the other case the sprite is updated.
        begin
          unless sprite.location.rect_inside?(sprite.rect) then
            sprite.destroy
            # @members.delete sprite
          else
            sprite.update
          end
        rescue NullLocation::NullLocationException
          Log4r::Logger['freeVikings log'].fatal "Sprite #{sprite} doesn't have it's 'location' attribute set to a valid Location class."
          raise
        end
      }
    end

    def pause
      @members.each {|m| m.pause}
    end

    def unpause
      @members.each {|m| m.unpause}
    end
  end # class SpriteManager
end #module FreeVikings
