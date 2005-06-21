# game.rb
# igneus 28.1.2005

# The Game class. (Documentation is in the code comments.)

require 'RUDL'

require 'viking.rb'
require 'hero.rb'
require 'team.rb'
require 'world.rb'
require 'location.rb'
require 'gamestate.rb'

module FreeVikings

=begin
= Game
All the stones which the house is built of are important. Classes are 
such stones. (({Game})) is a roof over the house made of stones. Since 
the roof is finished, you can live in the house. Roof makes the house 
habitable.
(({Game})) makes the game playable.

One Game object rules the program all the time we play.
It reacts on the events, updates the screen.

From it's internals I will mention one attribute - ((|@world|)).
It's a (({World})) object and contains information about locations which 
the vikings should explore and escape from. Maybe you expect another attribute 
which contains the currently loaded location. It isn't here, it's a local 
variable in method ((<Game#game_loop>)).

Then there is one more attribute. I don't want to talk much about it.
It's a bit stinking attribute... It's name is ((|@state|)). If you have ever 
heard about the Design patterns, you understand. When I was designing 
the (({Game})) class, I was really excited about the design patterns and 
I had a very nice idea of using the State design pattern to implement
the game menu etc. Now I think that idea isn't good any more and as soon as
I have a good mood for it, I will make ((|@state|)) go away.
=end
  class Game

    include RUDL
    include RUDL::Constant

=begin
== Constants

--- Game::VIKING_FACE_SIZE
--- Game::BOTTOMPANEL_HEIGHT
Code-explaining constants used almost to count up positions inside the game
window.
=end
    VIKING_FACE_SIZE = 60
    INVENTORY_VIEW_SIZE = 60
    LIVE_SIZE = 20
    BOTTOMPANEL_HEIGHT = VIKING_FACE_SIZE + LIVE_SIZE
    ITEM_SIZE = 30

=begin
== Public instance methods

--- Game.new(window, locations=[])
Argument ((|window|)) should be a RUDL::Surface (or RUDL::DisplaySurface).
It is used as a main game screen.
About the second argument, ((|locations|)), will I write later.
An initialization prepares the Game instance for use, but doesn't start 
the game. It doesn't change the contents of the window ((|window|)) and doesn't
receive any user events.
It means you theoretically could create two Game objects, both working with
the same window, and use them subsequently (or, if you were a devil, both
at once in a multithreaded application). But I wouldn't do that...

The main work of ((<Game::new>)) is to prepare the world (represented by an
instance of class World) for the vikings. The second argument, ((|locations|)),
says how to build that world.
* If ((|locations|)) is a World instance, it is used without any changes.
* If it's method empty? returns true, it is used as an Array of filenames
  relative to the 'locs' directory. (The 'locs' directory in freeVikings
  distribution contains locations in a form of XML.files.) All the listed 
  locations are loaded.
* If ((|locations|)) is empty, a global freeVikings configuration is searched
  for locations to load. If there aren't any, a default locations set is 
  loaded.

Examples:
* (({Game.new(win)}))
* (({Game.new(win, ["first_loc.xml", "pyramida_loc.xml"])}))
* (({Game.new(win, World.new("first_loc.xml", "pyramida_loc.xml"))}))

The first example initializes the game and loads the default level set.
The second and third one are equal, they both make a game with a world 
containing two specified locations, but the third one gives you more
freedom to make the world as you want it to be. (E.g. you don't have to use 
the standard World class.)
All the three examples expect you have created a RUDL::DisplaySurface 
((|win |)) before.
=end
    def initialize(window, locations=[])
      @app_window = window

      init_bottompanel_gfx

      if locations.is_a? World then
        @world = locations
      elsif not locations.empty?
        @world = World.new(*locations)
      elsif not FreeVikings::OPTIONS['locations'].empty?
        @world = World.new(*(FreeVikings::OPTIONS['locations']))
      else
        @world = World.new('pyramida_loc.xml',
                           'first_loc.xml',
                           'yellowhall.xml',
                           'hopsy_loc.xml')
      end

      # Surfaces, ktere se pouzivaji k sestaveni zobrazeni nahledu hraci plochy
      # a stavoveho radku s podobiznami vikingu
      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - BOTTOMPANEL_HEIGHT])
      @bottompanel_view = RUDL::Surface.new([WIN_WIDTH, BOTTOMPANEL_HEIGHT])

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = PlayingGameState.new(self)

      @give_up = nil
    end # initialize

    public

    attr_reader :app_window
    attr_reader :team

=begin
--- Game#give_up_game
This method is called by the GameState when a player presses
the give up key (F6 by default). Causes location reloading.
=end
    def give_up_game
	@give_up = true
    end

    def pause
      @world.location.pause
      @state = PausedGameState.new self
    end

    def unpause
      @world.location.unpause
      @state = PlayingGameState.new self
    end

=begin
--- Game#game_loop
When this method is called, the real fun begins (well, I know freeVikings
don't provide the real fun yet, but after a long startup procedure you
could think about the simple game like about a fun).
On the screen appears a strange place and three small vikings.
Method 'game_loop' contains two nested loops.
In the first one every iteration means one played location.
A new iteration starts whenever a player finishes or gives up a location
or if all the vikings are dead or if the remainder of them finishes the
location.
The second loop updates all the sprites (heroes and their enemies)
regularly and refreshes the screen.
=end
    def game_loop
      loop do
	if @team.nil? then
          location = @world.location
          init_vikings_team(location)
	elsif (@team.alive_size < @team.size) or (@give_up == true) then
	  # Nekteri hrdinove mrtvi.
	  puts '*** Some vikings died. Try once more.'
	  @world.rewind_location
          location = @world.location
          init_vikings_team(location)
	  @give_up = nil
	elsif @team.alive_size == @team.size
	  # Vsichni dosahli EXITu
	  puts '*** Oh, great! Congratulations, level completed.'
	  unless location = @world.next_location then
	    puts '*** Congratulations! You explored all the world!'
	    exit
	  end
          init_vikings_team(location)
	else
	  # Situace, ktera by nemela nastat
	  puts '*** Really strange situation. Nor the game loop is in it\'s first loop, nor the level completed, no vikings dead. Send a bug report, please.'
	  exit 1
	end


	frames = 0 # pomocna promenna k vypoctu fps

	# Cyklujeme, dokud se vsichni prezivsi nedostali do exitu
	# nebo to hrac nevzdal
	while (not is_exit?) and (not @give_up) do

	  # Zpracujeme udalosti:
	  if event = RUDL::EventQueue.poll then
	    @state.serve_event(event, location)
	  end # if je udalost

	  location.update unless @state.paused?

	  location.paint(@map_view, @team.active.center)
	  @app_window.blit(@map_view, [0,0])

	  repaint_bottompanel
	  @app_window.blit(@bottompanel_view, [0, WIN_HEIGHT - BOTTOMPANEL_HEIGHT])

	  if FreeVikings::OPTIONS["display_fps"] then
	    @app_window.filled_polygon [[8,8],[60,8],[60,20],[8,20]], [0,0,0]
            unless (s = Time.now.sec) == 0 
              @app_window.print([10,10], "fps: #{frames / s}", 0xFFFFFFFF)
            else
              frames = 0
            end
	  end

	  @app_window.flip
	  frames += 1
	  
	end # while not location.exited?
      end # while not self.game_over?
    end # game_loop

    private
    def init_bottompanel_gfx
      @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
      @item_bg = RUDL::Surface.load_new(GFX_DIR+'/item_bg.tga')
      @selection_box = RUDL::Surface.load_new(GFX_DIR+'/selection.tga')
      @energy_punkt = RUDL::Surface.load_new(GFX_DIR+'/energypunkt.tga')
    end # init_display

    # Method init_vikings_team must be called when a location is loaded
    # (or reloaded).
    # It recreates all the three vikings and sets them up
    # to start their way on the right place in the new loaded location.
    private
    def init_vikings_team(location)
      @baleog = Viking.createWarior("Baleog", location.start)
      @erik = Viking.createSprinter("Erik", location.start)
      @olaf = Viking.createShielder("Olaf", location.start)
      @team = Team.new(@erik, @baleog, @olaf)
      # vsechny vikingy oznacime jako hrdiny:
      @team.each { |v|
        v.extend Hero
        location.add_sprite v 
      }
    end # init_vikings_team

    private
    def repaint_bottompanel
      # vybarveni pozadi pro podobenky vikingu:
      @bottompanel_view.fill([60,60,60])
      i = 0

      @team.each { |vik|
        # paint face:
        face_position = [i * (INVENTORY_VIEW_SIZE + VIKING_FACE_SIZE), 0]
	@bottompanel_view.blit(@face_bg, face_position)
        portrait_img = if @team.active == vik && vik.alive? then
                         vik.portrait.active
                       elsif not vik.alive?
                         vik.portrait.kaput
                       else
                         vik.portrait.unactive
                       end
        @bottompanel_view.blit(portrait_img, face_position)
        # paint the lives:
        lives_y = VIKING_FACE_SIZE
        vik.energy.times {|j| 
          live_position = [face_position[0] + j * LIVE_SIZE, lives_y]
          @bottompanel_view.blit(@energy_punkt, live_position)
        }
        # paint inventory contents:
        item_positions = [[0,0],        [ITEM_SIZE,0],
                          [0,ITEM_SIZE],[ITEM_SIZE, ITEM_SIZE]]
        0.upto(3) do |k|
          item_position = [item_positions[k][0] + face_position[0] + VIKING_FACE_SIZE, item_positions[k][1]]
          @bottompanel_view.blit(@item_bg, item_position)
          next if vik.inventory[k].null?
          @bottompanel_view.blit(vik.inventory[k].image, item_position)
          if vik.inventory.active_index == k then
            if not (@state.paused? and Time.now.to_i % 2 == 0) then
              @bottompanel_view.blit(@selection_box, item_position)
            end
          end
        end

	i += 1
      }
    end # repaint_bottompanel

    private
    def is_exit?
      # Pokud vsichni umreli, koncime:
      unless @team.alive? then
	return true
      end
      # Pokud jsou vsichni zivi v exitu, koncime taky:
      if exited_sprites.size == @team.alive_size then
	return true
      end
      return nil
    end # is_exit?

    # Returns an Array with all the sprites colliding with the EXIT object.
    private
    def exited_sprites
      l = @world.location
      on_exit = l.sprites_on_rect(l.exitter.rect)
      on_exit.delete(l.exitter)
      exited_sprites = on_exit.find_all {|sprite| @team.member? sprite}
      return exited_sprites
    end

  end
end # module
