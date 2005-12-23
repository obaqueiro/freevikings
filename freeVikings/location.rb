# location.rb
# igneus 14.2.2005

=begin
= Location
(({Location})) object wraps all the data structures which together make
a level of the freeVikings game.
Methods are provided to access the members and their most important methods
are delegated.
=end

require 'forwardable'

#require 'map.rb'
require 'spritemanager.rb'
require 'ticker.rb'

module FreeVikings

  class Location

    extend Forwardable # for simple delegations

=begin

== Constructor

--- Location.new(loader, theme)
A new (({Location})) object is initialized using data given by the 
((|loader|)). The object given in parameter ((|loader|)) is expected to be
a (({LocationLoadStrategy})) instance or to provide the same public interface.
Argument ((|theme|)) is a (({GfxTheme})) instance.
=end

    def initialize(loader, theme=NullGfxTheme.instance)
      @exitter = nil # objekt Exit - cesta do dalsi lokace
      @start = [0,0] # misto, kde zacinaji vikingove svou misi

      @ticker = Ticker.new

      @theme = theme

      @map = Map.new(loader)
      @spritemanager = SpriteManager.new
      @activeobjectmanager = Group.new
      @itemmanager = Group.new

      @staticobjects = Group.new

      # a singleton method of @staticobjects:
      def @staticobjects.area_free?(rect)
        @members.find {|m|
          # Here the static objects are thought to be a px smaller than theit 
          # rects are. 
          # It's to enable the vikings to step onto a static object
          # where 
          # static_object.rect.top == ground
          # (It would normally collide with the viking and viking wouldn't
          # be able to step onto it which is illogical.)
          m.solid? and 
            m.rect.expand(-1,-1).collides?(rect)
        } == nil
      end

      loader.load_exit(self)
      loader.load_scripts(self)
      loader.load_start(self)
    end

=begin
== Attribute readers & writers

As mentioned above, ((<Location>)) is a thick data bundle.
You can access a lot of it's members directly through the accessor methods
documented below, a few are accessible through the delegated methods 
(which are listed in the ((<Actions>)) section) only.
=end

=begin
--- Location#ticker
Returns a (({Ticker})) object of the ((<Location>)). (({Ticker})) is a simple 
object which provides time information for the object 
inside the ((<Location>)).
=end

    attr_reader :ticker

=begin
--- Location#map
Returns a (({Map})) object which takes care of the tiles in the game.
=end

    attr_reader :map

=begin
--- Location#spritemanager
=end

    attr_reader :spritemanager

=begin
--- Location#activeobjectmanager
Returns an (({ActiveObjectManager})) which manages the ((<Location>))'s active 
objects. (To learn more about active objects study documentation for classes
(({ActiveObject})) and (({ActiveObjectManager})).)
=end

    attr_reader :activeobjectmanager

=begin
--- Location#staticobjects
Returns a (({Group})) of static objects (objects which aren't tiles but behave
as a part of map - they can be solid and aren't updated regularly.).
=end

    attr_reader :staticobjects
    alias_method :static_objects, :staticobjects

=begin
--- Location#exitter
--- Location#exitter=(exitter)
Methods to access ((<Location>))'s exitter. (({Exitter})) is 
a (({FreeVikings::Exit})) object. It is a special Sprite which denotes 
the exit point of the ((<Location>)).
The level is completed when all the three vikings stand on the exitter.
=end

    attr_reader :exitter

    def exitter=(exitter)
      @exitter = exitter
      @staticobjects.add exitter
      @exitter.location = self
    end

=begin
--- Location#start
Returns an (({Array})) of size 2 which contains the coordinates 
(in order [x,y] as usual) of the entry point of the ((<Location>)).
=end

    attr_accessor :start

=begin
--- Location#theme
Returns a (({GfxTheme})) instance with images specific for this (({Location})).
=end

    attr_reader :theme

=begin
--- Location#background
Returns a (({RUDL::Surface})) with (({Map})) blocks painted.
=end

    def background
      @map.background
    end

=begin
== Actions

--- Location#update
Updates everything which needs to be updated regularly. This method is called
once per game loop iteration, before refreshing the display.
=end

    def update
      @ticker.tick
      @spritemanager.update
    end

=begin
--- Location#pause
Tells all the (({Sprite}))s in the ((<Location>)) to temporarily stop 
all their activities.
=end

    def pause
      @spritemanager.pause
    end

=begin
--- Location#unpause
Unpauses the (({Sprite}))s after ((<Location#pause>)).
=end

    def unpause
      @ticker.restart
      @spritemanager.unpause
    end

=begin
--- Location#paint(surface, center)
Paints a cutout (centered with ((|center|))) of it's contents (map blocks,
sprites, items etc.) onto ((|surface|)).
((|surface|)) must be of type (({RUDL::Surface})), ((|center|)) is expected 
to be an (({Array})) of size 2 containing valid horizontal and vertical 
coordinate.
=end

    def paint(surface, center)
      mr = @map.rect
      displayed_rect = centered_view_rect(mr.w, mr.h, surface.w, surface.h, center)

      @map.paint(surface, displayed_rect)
      @staticobjects.paint(surface, displayed_rect)
      @activeobjectmanager.paint(surface, displayed_rect)
      @itemmanager.paint(surface, displayed_rect)
      @spritemanager.paint(surface, displayed_rect)
    end

=begin
== In-Game objects addition, removal and collisions

--- Location#<<(object)
The same as

object.register_in(location)

This is more intuitive and so more readable.
=end

    def <<(object)
      object.register_in self
    end

=begin
=== Sprites
--- Location#add_sprite(sprite)
--- Location#delete_sprite(sprite)
--- Location#sprites_on_rect(rect)

((<Location#add_sprite>)) and ((<Location#delete_sprite>)) have an important 
side effect. They set the argument's attribute 'location'. 
(((<Location#add_sprite>)) sets it to the location itself, 
((<Location#delete_sprite>)) to the (({NullLocation})) instance (which
is a null object)).
=end

    def add_sprite(sprite)
      sprite.location = self
      @spritemanager.add sprite
    end

    def delete_sprite(sprite)
      @spritemanager.delete sprite
      sprite.location = NullLocation.instance
    end

    def_delegator :@spritemanager, :members_on_rect, :sprites_on_rect

=begin
--- Location#heroes_on_rect(rect)
--- Location#monsters_on_rect(rect)
A bit quicker alternatives for ((<Location#sprites_on_rect>)) which
return only an (({Array})) of ((|rect|)) colliding (({Hero}))es or
(({Monster}))s respectively.
=end

    def_delegator :@spritemanager, :heroes_on_rect
    def_delegator :@spritemanager, :monsters_on_rect

=begin
=== Active Objects
--- Location#add_active_object(object)
--- Location#delete_active_object(object)
--- Location#active_objects_on_rect(rect)
=end

    def_delegator :@activeobjectmanager, :add, :add_active_object
    def_delegator :@activeobjectmanager, :delete, :delete_active_object
    def_delegator :@activeobjectmanager, :members_on_rect, :active_objects_on_rect

=begin
=== Items
--- Location#add_item(item)
--- Location#delete_item(item)
--- Location#items_on_rect(rect)
=end

    def_delegator :@itemmanager, :add, :add_item
    def_delegator :@itemmanager, :delete, :delete_item
    def_delegator :@itemmanager, :members_on_rect, :items_on_rect

=begin
=== Static Objects
--- Location#add_static_object(static_object)
--- Location#delete_static_object(static_object)
--- Location#static_objects_on_rect(rect)
=end

    def_delegator :@staticobjects, :add, :add_static_object
    def_delegator :@staticobjects, :delete, :delete_static_object
    def_delegator :@staticobjects, :members_on_rect, :static_objects_on_rect

=begin
== Predicates

--- Location#rect_inside?(rect)
Returns ((|true|)) if (({Rectangle})) ((|rect|)) or it's part is inside 
the ((<Location>)) or ((|false|)) if it isn't.
=end

    def rect_inside?(rect)
      @map.rect.collides? rect
    end

=begin
--- Location#area_free?(rect)
Returns ((|true|)) if area specified by the (({Rectangle})) ((|rect|)) 
is free of solid map blocks, ((|false|)) otherwise.
=end

    def area_free?(rect)
      @map.area_free?(rect) and @staticobjects.area_free?(rect)
    end

    alias_method :is_area_free?, :area_free?

    private

    # vraci pole ctyr prvku definujicich obdelnik centrovany predanymi 
    # souradnicemi bodu, pokud tyto souradnice nejsou moc blizko okrajum
    # plochy
    # width, height - sirka a vyska plochy, po ktere se pohybujeme
    # view_width, view_height - sirka a vyska zobrazeni
    # center_coord - souradnice pozadovaneho stredu

    def centered_view_rect(width, height, view_width, view_height, center_coord)
      # vypocet leve souradnice leveho horniho rohu:
      if center_coord[0] < (view_width / 2)
	# stred moc u zacatku
	top_left_left = 0
      elsif center_coord[0] > (width - (view_width / 2))
	# stred moc u konce
	top_left_left = width - view_width
      else
	top_left_left = center_coord[0] - (view_width / 2)
      end
      # vypocet svrchni souradnice leveho horniho rohu:
      if center_coord[1] < (view_height / 2)
	# stred moc u zacatku
	top_left_top = 0
      elsif center_coord[1] > (height - (view_height / 2))
	# stred moc u konce
	top_left_top = height - view_height
      else
	top_left_top = center_coord[1] - (view_height / 2)
      end
      bottom_right_left = top_left_left + view_width
      bottom_right_top = top_left_top + view_height

      return Rectangle.new(top_left_left, top_left_top, 
                           bottom_right_left, bottom_right_top)
    end

  end # class Location
end # module FreeVikings

require 'nullocation.rb'
