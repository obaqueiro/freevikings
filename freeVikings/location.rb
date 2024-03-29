# location.rb
# igneus 14.2.2005

require 'forwardable'
require 'zsortedgroup.rb'

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

    def initialize(loader, theme)
      @log = Log4r::Logger['freeVikings log']

      @exitter = nil # objekt Exit - cesta do dalsi lokace
      @start = [0,0] # misto, kde zacinaji vikingove svou misi

      @ticker = Ticker.new

      @theme = theme
      if @theme.is_a? NullGfxTheme then
        @log.error "Location got NullGfxTheme instead of GfxTheme."
        # raise ArgumentError, "Location can't be initialized with a null theme."
      end

      @map = Map.new(loader.map_loader)

      @spritemanager = SpriteManager.new
      @activeobjectmanager = Group.new
      @itemmanager = Group.new
      @staticobjects = Group.new
      @objects = ZSortedGroup.new # Group of all objects

      @talk = nil # Slot for a Talk. 
      # (one talk at a time can be running in a Location)

      @story = nil # Slot for a Story

      # From a script 'event handler' Procs can be assigned to these variables
      @on_exit = nil
      @on_beginning = nil

      # Says if the game has already started
      @started = false

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

      def @staticobjects.find_surface(rect)
        su = nil

        @members.each do |m|
          if m.at_least_semisolid? then
            # surface inside the searched rect?
            if m.rect.top >= rect.top && m.rect.collides?(rect) then
              # is it the highest one?
              if (su == nil) || (m.rect.top < su.top) then
                su = m.rect
              end
            end
          end
        end

        return su
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

    # Says if the location has been exitted (it means 1. all team members 
    # reached exit and 2. end story - if exists - has been finished)

    def exitted?
      if @exitter.team_exited?(@team) && (@story == nil) && (@talk == nil) then
        if @on_exit == nil then
          return true
        else
          # If on_exit event handler is given, execute it and check
          # exit conditions again (on_exit handler usually starts
          # some Story...) 
          @on_exit.call
          @on_exit = nil
          return exitted?
        end
      else
        return false
      end
    end

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
      @exitter.location = self
      @objects.add @exitter
    end

    # Returns an Array of size 2 which contains the coordinates 
    # (in order [x,y] as usual) of the entry point of the Location.

    attr_accessor :start

    # Returns a GfxTheme instance with images specific for this Location.

    attr_reader :theme

    # == Talk related methods

    # Starts a new talk.
    # Doesn't start (Location#start) it - it must have been started 
    # from elsewhere (usually from location script).

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

    # == Story related methods

    # location.story = s
    # starts the new story immediately!

    attr_accessor :story

    def story_next
      if ! @story then
        raise RuntimeError, "No story is being told."
      end

      @story.next
      if @story.story_completed? then
        @story = nil
      end
    end

    # == Procs on_beginning and on_exit
    # You can set up "event handlers" for two "events": location
    # being started and exitted.
    # 'on_beginning' is called on every start of the location;
    # 'on_exit' is called if all members of the team successfully reached
    # exit

    attr_accessor :on_exit

    attr_accessor :on_beginning

    # == Actions

    # Updates everything which needs to be updated regularly. This method 
    # is called
    # once per game loop iteration, before refreshing the display.
    #
    # When it is called at the first time, calls the 'on_beginning' Proc

    def update
      if ! @started then
        @started = true
        if @on_beginning != nil then
          @on_beginning.call
          @on_beginning = nil
        end
      end

      @ticker.tick

      @spritemanager.each do |sprite|
        sprite.update
        unless rect_inside?(sprite.collision_rect)
          sprite.destroy
        end
      end
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

      # In a 'story telling mode' we only display current story frame:
      if @story then
        @story.paint(surface)
        return
      end

      mr = @map.rect
      surfr = Rectangle.new(*surface.clip)
      displayed_rect = centered_view_rect(mr.w, mr.h, surfr.w, surfr.h, center)

      @map.paint_background(surface, displayed_rect)

      @objects.members_on_rect(displayed_rect) {|o|
        offset = [surfr.left + (o.paint_rect.left - displayed_rect.left), 
                  surfr.top + (o.paint_rect.top - displayed_rect.top)]

        surface.blit o.image, offset
      }

      @map.paint_foreground(surface, displayed_rect)
    end

    # Shortcuts for creating instance methods of Location which add/delete
    # object in given group and give/take from him reference to self.
    # Ignore them if you aren't working on Location itself...

    def Location.def_add(group, object_name)
      module_eval ""\
      "def add_#{object_name}(o)\n"\
      "  #{group}.add o\n"\
      "  @objects.add o\n"\
      "  put_self o\n"\
      "end"
    end

    def Location.def_delete(group, object_name)
      module_eval ""\
      "def delete_#{object_name}(o)\n"\
      "  #{group}.delete o\n"\
      "  @objects.delete o\n"\
      "  unless @objects.include?(o)\n"\
      "    put_nulllocation o\n"\
      "  end\n"\
      "end"
    end

    # == In-Game objects addition, removal and collisions

    # The same as
    # object.register_in(location)
    # This is more intuitive and so more readable.

    def <<(object)
      object.register_in self
      put_self object
      return self
    end

    def_add :@spritemanager, 'sprite'
    def_delete :@spritemanager, 'sprite'

    def_delegator :@spritemanager, :members_on_rect, :sprites_on_rect

    # A bit quicker alternatives for Location#sprites_on_rect which
    # return only an Array of rect colliding Heroes or
    # Monsters respectively.

    def_delegator :@spritemanager, :heroes_on_rect
    def_delegator :@spritemanager, :monsters_on_rect

    # === Active Objects

    def_add :@activeobjectmanager, 'active_object'
    def_delete :@activeobjectmanager, 'active_object'

    def_delegator :@activeobjectmanager, :members_on_rect, :active_objects_on_rect

    # === Items

    def_add :@itemmanager, 'item'
    def_delete :@itemmanager, 'item'

    def_delegator :@itemmanager, :members_on_rect, :items_on_rect

    # === Static Objects

    def_add :@staticobjects, 'static_object'
    def_delete :@staticobjects, 'static_object'

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

    # See documentation of SchwerEngine::Map#find_surface for what it does;
    # in addition to searching Map, also static objects are searched 
    # for surface.

    def find_surface(rect)
      s_map = @map.find_surface rect
      s_stos = @staticobjects.find_surface rect      

      # Return the highest of surfaces found:
      if s_map == nil then
        return s_stos
      elsif s_stos == nil then
        return s_map
      elsif s_map.top < s_stos.top then
        return s_map
      else
        return s_stos
      end
    end

    # Returns rectangle of the map to be displayed (see 
    # Location#centered_view_rect for rules)

    def display_rect(w,h)
      mr = @map.rect
      a = @team.active.rect.center
      return centered_view_rect(mr.w, mr.h, w, h, a)
    end

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

      # sort vikings according to the configuration
      names = {
        'baleog' => baleog, 
        'erik' => erik, 'eric' => erik,
        'olaf' => olaf
      }
      vikings = []
      FreeVikings::CONFIG['Game']['order of vikings'].each {|name|
        vikings.push(names[name.downcase])
      }

      @team = Team.new(*vikings)
      
      team.each { |v|
        v.extend Hero # label all vikings as heroes
        self.add_sprite v # and add them into the location
      }
    end

    # Gives reference of self to object

    def put_self(object)
      if object.location != self then
        object.location = self
      end
    end

    # gives reference of NullLocation to object

    def put_nulllocation(object)
      if object.location == self then
        object.location = NullLocation.instance
      end
    end

  end # class Location
end # module
