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

require 'map.rb'
require 'spritemanager.rb'
require 'activeobjectmanager.rb'
require 'itemmanager.rb'
require 'ticker.rb'
require 'gfxtheme.rb'

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
      @activeobjectmanager = ActiveObjectManager.new
      @itemmanager = ItemManager.new
      loader.load_exit(self)
      loader.load_scripts(self)
      loader.load_start(self)
    end

=begin
== Attribute readers & writers

As mentioned above, ((<Location>)) is a thick data bundle.
You can access a lot of it's members directly through the accessor methods
documented above, a few are accessible through the delegated methods 
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
Returns a (({Map})) object which takes care of the static objects 
(mainly blocks) in the game.
=end

    attr_reader :map

=begin
--- Location#activeobjectmanager
Returns an (({ActiveObjectManager})) which manages the ((<Location>))'s active 
objects. (To learn more about active objects study documentation for classes
(({ActiveObject})) and (({ActiveObjectManager})).)
=end

    attr_reader :activeobjectmanager

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
      add_sprite exitter
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
== Actions
=end

=begin
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
      @map.paint(surface, center)
      displayed_rect = centered_view_rect(background.w, background.h, surface.w, surface.h, center)
      @activeobjectmanager.paint(surface, displayed_rect)
      @itemmanager.paint(surface, displayed_rect)
      @spritemanager.paint(surface, displayed_rect)
    end

=begin
--- Location#background
Returns a (({RUDL::Surface})) with (({Map})) blocks painted.
=end

    def background
      @map.background
    end

=begin
--- Location#add_sprite(sprite)
Adds the (({Sprite})) ((|sprite|)) into the ((<Location>)). As a side effect
((|sprite|))'s attribute 'location' is set to the ((<Location>)) itself.
=end

    def add_sprite(sprite)
      sprite.location = self
      @spritemanager.add sprite
    end

=begin
--- Location#delete_sprite(sprite)
Deletes the (({Sprite})) ((|sprite|)) from the ((<Location>)). As a side 
effect sets ((|sprite|))'s attribute 'location' to a (({NullLocation})) object.
=end

    def delete_sprite(sprite)
      @spritemanager.delete sprite
      sprite.location = NullLocation.instance # nullocation.rb is required at 
                                              # the end of file
    end

=begin
--- Location#sprites_on_rect(rect)
Returns an (({Array})) of all the (({Sprite}))s colliding with 
a (({Rectangle})) ((|rect|)). Type of ((|rect|)) must be (({Rectangle})) or 
any other which responds to 'collides?'.
=end

    def_delegator :@spritemanager, :members_on_rect, :sprites_on_rect

=begin
--- Location#add_active_object(object)
Adds an (({ActiveObject})) into the ((<Location>)).
=end

    def_delegator :@activeobjectmanager, :add, :add_active_object

=begin
--- Location#delete_active_object(object)
Deletes an (({ActiveObject})) from the ((<Location>)).
=end

    def_delegator :@activeobjectmanager, :delete, :delete_active_object

=begin
--- Location#active_objects_on_rect(rect)
=end

    def_delegator :@activeobjectmanager, :members_on_rect, :active_objects_on_rect

=begin
--- Location#add_item(item)
=end

    def_delegator :@itemmanager, :add, :add_item

=begin
--- Location#delete_item(item)
=end

    def_delegator :@itemmanager, :delete, :delete_item

=begin
--- Location#items_on_rect(rect)
=end

    def_delegator :@itemmanager, :members_on_rect, :items_on_rect

=begin
== Predicates
=end

=begin
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
      @map.area_free? rect
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
      Rectangle.new(top_left_left, top_left_top, bottom_right_left, bottom_right_top)
    end

  end # class Location
end # module FreeVikings

require 'nullocation.rb'
