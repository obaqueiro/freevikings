# location.rb
# igneus 14.2.2005

require 'forwardable'

module FreeVikings

  # Location object wraps all the data structures which together make
  # a level of the freeVikings game.
  # Methods are provided to access the members and their most important methods
  # are delegated.

  class Location

    extend Forwardable # for simple delegations

    # == Constructor

    # A new Location object is initialized using data given by the 
    # loader. The object given in parameter loader is expected to be
    # a LocationLoadStrategy instance or to provide the same public interface.
    # Argument theme is a GfxTheme instance.

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

      @talk = nil # one talk at a time can be running in a Location

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
      loader.load_start(self)

      init_vikings_team

      loader.load_script(self)
    end

    # == Attribute readers & writers
    #
    # As mentioned above, Location is a thick data bundle.
    # You can access a lot of it's members directly through the accessor 
    # methods
    # documented below, a few are accessible through the delegated methods 
    # (which are listed in the Actions section) only.

    # Team of Vikings.

    attr_reader :team

    # Returns a Ticker object of the Location. Ticker is a simple 
    # object which provides time information for the object 
    # inside the Location.

    attr_reader :ticker

    # Returns a Map object which takes care of the tiles in the game.

    attr_reader :map

    attr_reader :spritemanager

    attr_reader :activeobjectmanager

    # Returns a Group of static objects (objects which aren't tiles but behave
    # as a part of map - they can be solid and aren't updated regularly.).

    attr_reader :staticobjects
    alias_method :static_objects, :staticobjects

    # Methods to access Location's exitter. Exitter is 
    # a SchwerEngine::Exit object. It is a special Sprite which denotes 
    # the exit point of the Location.
    # The level is completed when all the three vikings stand on the exitter.

    attr_reader :exitter

    def exitter=(exitter)
      @exitter = exitter
      @staticobjects.add exitter
      @exitter.location = self
    end

    # Returns an Array of size 2 which contains the coordinates 
    # (in order [x,y] as usual) of the entry point of the Location.

    attr_accessor :start

    # Returns a GfxTheme instance with images specific for this Location.

    attr_reader :theme

    # Starts a new talk.
    # Doesn't start it - it must have been started from elsewhere
    # (usually from location script).

    def talk=(t)
      if @talk then
        raise RuntimeError, "Cannot start a new talk. One talk is already running."
      end

      @talk = t
      @talk.next
    end

    # Returns current Talk.

    attr_reader :talk

    # Asks for new speech of the running talk.

    def talk_next
      if ! @talk then
        raise RuntimeError, "No talk is running."
      end

      @talk.next
      if @talk.talk_completed? then
        @talk = nil
      end
    end

    # Returns a RUDL::Surface with Map blocks painted.

    def background
      @map.background
    end

    # == Actions

    # Updates everything which needs to be updated regularly. This method 
    # is called
    # once per game loop iteration, before refreshing the display.

    def update
      @ticker.tick
      @spritemanager.update
    end

    # Tells all the Sprites in the Location to temporarily stop 
    # all their activities.

    def pause
      @spritemanager.pause
    end

    # Unpauses the Sprites after Location#pause.

    def unpause
      @ticker.restart
      @spritemanager.unpause
    end

    # Paints a cutout (centered with center) of it's contents (map blocks,
    # sprites, items etc.) onto surface.
    # surface must be of type RUDL::Surface, center is expected 
    # to be an Array of size 2 containing valid horizontal and vertical 
    # coordinate.

    def paint(surface, center)
      mr = @map.rect
      displayed_rect = centered_view_rect(mr.w, mr.h, surface.w, surface.h, center)

      @map.paint(surface, displayed_rect)
      @staticobjects.paint(surface, displayed_rect)
      @activeobjectmanager.paint(surface, displayed_rect)
      @itemmanager.paint(surface, displayed_rect)
      @spritemanager.paint(surface, displayed_rect)
    end

    # == In-Game objects addition, removal and collisions

    # The same as
    # object.register_in(location)
    # This is more intuitive and so more readable.

    def <<(object)
      object.register_in self
      return self
    end

    # Location#add_sprite and Location#delete_sprite have an important 
    # side effect. They set the argument's attribute 'location'. 
    # Location#add_sprite sets it to the location itself, 
    # Location#delete_sprite to the NullLocation instance (which
    # is a null object)).

    def add_sprite(sprite)
      sprite.location = self
      @spritemanager.add sprite
    end

    def delete_sprite(sprite)
      @spritemanager.delete sprite
      sprite.location = NullLocation.instance
    end

    def_delegator :@spritemanager, :members_on_rect, :sprites_on_rect

    # A bit quicker alternatives for Location#sprites_on_rect which
    # return only an Array of rect colliding Heroes or
    # Monsters respectively.

    def_delegator :@spritemanager, :heroes_on_rect
    def_delegator :@spritemanager, :monsters_on_rect

    # === Active Objects

    def add_active_object(o)
      @activeobjectmanager.add o
      o.location = self
    end

    def delete_active_object(o)
      @activeobjectmanager.delete o
      o.location = NullLocation.instance
    end

    def_delegator :@activeobjectmanager, :members_on_rect, :active_objects_on_rect

    # === Items

    def_delegator :@itemmanager, :add, :add_item
    def_delegator :@itemmanager, :delete, :delete_item
    def_delegator :@itemmanager, :members_on_rect, :items_on_rect

    # === Static Objects

    def_delegator :@staticobjects, :add, :add_static_object
    def_delegator :@staticobjects, :delete, :delete_static_object
    def_delegator :@staticobjects, :members_on_rect, :static_objects_on_rect

    # == Predicates

    # Returns true if Rectangle rect or it's part is inside 
    # the Location or false if it isn't.

    def rect_inside?(rect)
      @map.rect.collides? rect
    end

    # Returns true if area specified by the Rectangle rect 
    # is free of solid map blocks, false otherwise.

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

    # Method init_vikings_team must be called when a location is loaded
    # (or reloaded).
    # Creates all the three vikings and sets them up
    # to start their way on the right place

    def init_vikings_team
      baleog = Viking.createWarior("Baleog", self.start)
      erik = Viking.createSprinter("Erik", self.start)
      olaf = Viking.createShielder("Olaf", self.start)
      @team = Team.new(erik, baleog, olaf)
      
      team.each { |v|
        v.extend Hero # label all vikings as heroes
        self.add_sprite v # and add them into the location
      }
    end

  end # class Location
end # module
