# game.rb
# igneus 28.1.2005

# The Game class. (Documentation is in the code comments.)

require 'RUDL'

require 'viking.rb'
require 'hero.rb'
require 'team.rb'
require 'world.rb'
require 'structuredworld.rb'
require 'location.rb'
require 'gamestate.rb'
require 'bottompanel.rb'

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

      @log = Log4r::Logger['init log']

      # set defaults:
      levelset = 'locs/DefaultCampaign'
      startpassword = nil

      # some defaults can be redefined by the player's options:
      if FreeVikings::OPTIONS['levelset']
        levelset = FreeVikings::OPTIONS['levelset']
      end
      if FreeVikings::OPTIONS['startpassword']
        startpassword = FreeVikings::OPTIONS['startpassword']
      else
        startpassword = ''
      end

      if locations.is_a? World then
        @world = locations
      elsif not locations.empty?
        @world = World.new(*locations)
      else
        @world = StructuredWorld.new(levelset, startpassword)
      end

      # Surfaces, ktere se pouzivaji k sestaveni zobrazeni nahledu hraci plochy
      # a stavoveho radku s podobiznami vikingu
      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - BottomPanel::HEIGHT])

      @loading_message = FreeVikings::FONTS['default'].create_text_box(120, 'LOADING')

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = nil
      @bottompanel = nil

      @give_up = nil
    end # initialize

    public

    attr_reader :app_window
    attr_reader :team
    attr_reader :bottompanel

=begin
--- Game#give_up_game
This method is called by the GameState when a player presses
the give up key (F6 by default). Causes location reloading.
=end

    def give_up_game
	@give_up = true
    end

=begin
--- Game#exit_game
Exits the game.
=end

    def exit_game
      throw :return_to_menu
    end

=begin
--- Game#pause
Pauses all the (({Sprite}))s and switches into the inventory browsing mode.
=end

    def pause
      @world.location.pause
      @state = PausedGameState.new self
    end

=begin
--- Game#unpause
After ((<Game#pause>)) switches back to the playing mode and unpauses the
(({Sprite}))s.
=end

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
        paint_loading_screen(@app_window)

	if @team.nil? then
          level = location = nil
          level = @world.level
	elsif (@team.alive_size < @team.size) or (@give_up == true) then
	  # Some of the heroes are dead.
	  @log.info "Some vikings died. Try once more."
          level = @world.level
	  @give_up = nil
	elsif @team.alive_size == @team.size then
	  # All of the vikings have reached the EXIT
	  @log.info "Level completed."
	  unless level = @world.next_level
            p location
	    @log.info "Congratulations! You explored all the world!"
            @state = AllLocationsFinishedGameState.new self
	  end
	else
	  # Situation which shouldn't ever occur
	  raise FatalError, '*** Really strange situation. Nor the game loop is in it\'s first loop, nor the level completed, no vikings dead. Send a bug report, please.'
	end

        # This paragraph of code is important for a good work of
        # the text displayed at the end of the game. Be careful when
        # modifying it, there's some black magic!
        unless is_game_finished?
          location = @world.rewind_location 
          @team = init_vikings_team(location)
          @state = LocationInfoGameState.new(self, level)
        else
          location = @world.location
        end

        @bottompanel = BottomPanel.new @team

	frames = 0 # auxiliary variable for fps computing

        if FreeVikings::OPTIONS['profile'] then
          Profiler__::start_profile
        end

        # In this cycle one level is played until it is given up or finished.
	while (not is_exit?) and (not @give_up) do

	  # Serve events:
	  RUDL::EventQueue.get.each do |event|
	    @state.serve_event(event, location)
	  end

          @team.next unless @team.active.alive?

	  location.update unless @state.paused?

	  location.paint(@map_view, @team.active.center)
	  @app_window.blit(@map_view, [0,0])

          @state.change_view(@app_window)

	  @app_window.blit(@bottompanel.image, [0, WIN_HEIGHT - BottomPanel::HEIGHT])

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
	  
	end # while (not is_exit?) and (not @give_up)

        if FreeVikings::OPTIONS['profile'] then
          exit # the END block which prints out profiler output will be called
        end

      end # loop
    end # public method game_loop

=begin
--- Game#run_location(location)
This method is called from (({LocationInfoGameState})) to start playing.
The vikings are put into the (({Location})) and fun starts.
=end

    def run_location(location)
      @team.each {|viking| 
        location.add_sprite viking
      }

      @state = PlayingGameState.new self
    end

    # Method init_vikings_team must be called when a location is loaded
    # (or reloaded).
    # It recreates all the three vikings and sets them up
    # to start their way on the right place in the new loaded location.
    private
    def init_vikings_team(location)
      @baleog = Viking.createWarior("Baleog", location.start)
      @erik = Viking.createSprinter("Erik", location.start)
      @olaf = Viking.createShielder("Olaf", location.start)
      team = Team.new(@erik, @baleog, @olaf)
      # vsechny vikingy oznacime jako hrdiny:
      team.each { |v|
        v.extend Hero
      }
      team
    end # init_vikings_team

    private
    def is_exit?
      if is_game_finished? then
        return false
      else
        return @world.location.exitter.team_exited?(@team)
      end
    end # is_exit?

    private
    def is_game_finished?
      @state.kind_of? AllLocationsFinishedGameState
    end

    private
    def paint_loading_screen(screen)
      screen.fill 0x0000000
      screen.blit(@loading_message, [280,180])
      screen.flip
    end
  end # class Game
end # module FreeVikings
