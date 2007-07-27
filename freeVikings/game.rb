# game.rb
# igneus 28.1.2005

require 'RUDL'

require 'viking.rb'
require 'team.rb'
require 'world.rb'
require 'structuredworld.rb'
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

--- Game.new(window, password='')
Argument ((|window|)) should be a RUDL::Surface (or RUDL::DisplaySurface).
It is used as a main game screen.
About the second argument, ((|locations|)), will I write later.
An initialization prepares the Game instance for use, but doesn't start 
the game. It doesn't change the contents of the window ((|window|)) and doesn't
receive any user events.
It means you theoretically could create two Game objects, both working with
the same window, and use them subsequently (or, if you were a devil, both
at once in a multithreaded application). But I wouldn't do that...
=end
    def initialize(window, startpassword='')
      @app_window = window

      @log = Log4r::Logger['init log']

      @loading_message = FreeVikings::FONTS['default'].create_text_box(120, 'LOADING')

      paint_loading_screen @app_window

      levelset = FreeVikings::OPTIONS['levelset']

      begin
        @world = StructuredWorld.new(levelset, startpassword)
      rescue StructuredWorld::PasswordError => pe
        @log.error pe.message
        @log.error "Password start failed, restarting without password"
        startpassword = ''
        retry
      rescue LevelSuite::LevelSuiteLoadException => lle
        @log.error "Could not load LevelSuite from directory '#{levelset}'. Setting default directory (#{FreeVikings::DEFAULT_LEVELSET_DIR})."
        levelset = DEFAULT_LEVELSET_DIR
        retry
      end

      # Surface used to build the "picture" of a part of map and game objects
      # which is then displayed on the screen
      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - BottomPanel::HEIGHT])

      # State of the game (GameState instance).
      @state = nil

      @bottompanel = nil

      @give_up = nil
    end # initialize

    public

=begin
--- Game#app_window
(({RUDL::DisplaySurface})) on which the game world is displayed.
It's that one which was given as an argument to the constructor.
=end

    attr_reader :app_window

=begin
--- Game#team
Returns (({Team})) of vikings.
=end

    attr_reader :team

=begin
--- Game#bottompanel
(({BottomPanel})) which displays the vikings' portraits, life statistics
and inventories.
=end

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
The nested loop updates all the sprites (heroes and their enemies)
regularly and refreshes the screen.
=end
    def game_loop
      loop do 
        paint_loading_screen @app_window

	if @team.nil? then
          level = location = nil
          level = @world.level
	elsif (@team.alive_size < @team.size) or (@give_up == true) then
          if @give_up == true then
            @log.info "Game given up. Try once more."
          else
            @log.info "Some vikings died. Try once more."
          end
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

        # The "event loop": serve events, update game state
	while (not is_exit?) and (not @give_up) do

	  # Serve events:
	  RUDL::EventQueue.get.each do |event|
	    @state.serve_event(event, location)
	  end

          unless @team.active.alive?
            @team.next
          end

          # nearly all the game state (position of heroes etc.) is updated here
	  location.update unless @state.paused?

	  location.paint(@map_view, @team.active.center)
	  @app_window.blit(@map_view, [0,0])

          @state.change_view(@app_window)

	  @app_window.blit(@bottompanel.image, [0, WIN_HEIGHT - BottomPanel::HEIGHT])

	  if FreeVikings.display_fps? then
	    @app_window.filled_polygon [[8,8],[60,8],[60,20],[8,20]], [0,0,0]
            unless (s = Time.now.sec) == 0 
              @app_window.print([10,10], "fps: #{frames / s}", 0xFFFFFFFF)
            else
              frames = 0
            end
	  end

          if FreeVikings::OPTIONS['delay'] != 0 then
            sleep(FreeVikings::OPTIONS['delay'])
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
