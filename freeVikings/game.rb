# game.rb
# igneus 28.1.2005

require 'RUDL'

require 'viking.rb'
require 'team.rb'

require 'location.rb'
require 'nullocation.rb'

require 'structuredworld.rb'
require 'gamestate.rb'
require 'bottompanel.rb'

module FreeVikings

  # All the stones which the house is built of are important. Classes are 
  # such stones. Game is a roof over the house made of stones. Since 
  # the roof is finished, you can live in the house. Roof makes the house 
  # habitable.
  # Game makes the game playable.
  #
  # One Game object rules the program all the time we play.
  # It reacts on the events, updates the screen.
  #
  # From it's internals I will mention one attribute - @world.
  # It's a World object and contains information about locations which 
  # the vikings should explore and escape from. Maybe you expect another attribute 
  # which contains the currently loaded location. It isn't here, it's a local 
  # variable in method Game#game_loop.
  #
  # Then there is one more attribute. I don't want to talk much about it.
  # It's a bit stinking attribute... It's name is @state. If you have ever 
  # heard about the Design patterns, you understand. When I was designing 
  # the Game class, I was really excited about the design patterns and 
  # I had a very nice idea of using the State design pattern to implement
  # the game menu etc. Now I think that idea isn't good any more and as soon as
  # I have a good mood for it, I will make @state go away.

  class Game

    include RUDL
    include RUDL::Constant

    # == Public instance methods
    #
    # Argument window should be a RUDL::Surface (or RUDL::DisplaySurface).
    # It is used as a main game screen.
    # About the second argument, locations, will I write later.
    # An initialization prepares the Game instance for use, but doesn't start 
    # the game. It doesn't change the contents of the window window and doesn't
    # receive any user events.
    # It means you theoretically could create two Game objects, both working with
    # the same window, and use them subsequently (or, if you were a devil, both
    # at once in a multithreaded application). But I wouldn't do that...

    def initialize(window, startpassword='')
      @app_window = window

      @log = Log4r::Logger['init log']

      @loading_message = FreeVikings::FONTS['default'].create_text_box(120, 'LOADING')

      paint_loading_screen @app_window

      levelset = FreeVikings::OPTIONS['levelsuite']

      begin
        @world = StructuredWorld.new(levelset, startpassword)
      rescue StructuredWorld::PasswordError => pe
        @log.error pe.message
        @log.error "Password start failed, restarting without password"
        startpassword = ''
        retry
      rescue LevelSuite::LevelSuiteLoadException => lle
        @log.error "Could not load LevelSuite from directory '#{levelset}'. Setting default directory (#{FreeVikings::DEFAULT_LEVELSUITE_DIR})."
        levelset = DEFAULT_LEVELSUITE_DIR
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

    # RUDL::DisplaySurface on which the game world is displayed.
    # It's that one which was given as an argument to the constructor.
    attr_reader :app_window

    def team
      @world.location.team
    end

    # BottomPanel which displays the vikings' portraits, life statistics
    # and inventories.
    attr_reader :bottompanel

    # This method is called by the GameState when a player presses
    # the give up key (F6 by default). Causes location reloading.

    def give_up_game
      @give_up = true
    end

    # Returns to the menu.

    def exit_game
      on_level_end
      throw :return_to_menu
    end

    # Pauses all the Sprites and switches into the inventory browsing mode.

    def pause
      @world.location.pause
      @state = PausedGameState.new self
    end

    # Similar to Game#pause, but switches to ConversationGameState instead of
    # PausedGameState.
    # Return back to PlayingGameState by call to Game#unpause.

    def go_conversation
      @world.location.pause
      @state = ConversationGameState.new self
    end

    # Very, very similar to Game#go_conversation,
    # but used when Story occurs (instead of Talk)

    def go_story
      @world.location.pause
      @state = StoryGameState.new self
    end

    # After Game#pause switches back to the playing mode and unpauses 
    # the Sprites

    def unpause
      @world.location.unpause
      @state = PlayingGameState.new self
    end

    # Switches to the "development magic" mode (special level testing features)

    def go_develmagic
      @state = DevelopmentMagicGameState.new self
    end

    # When this method is called, the real fun begins (well, I know freeVikings
    # don't provide the real fun yet, but after a long startup procedure you
    # could think about the simple game like about a fun).
    # On the screen appears a strange place and three small vikings.
    # Method 'game_loop' contains two nested loops.
    # In the first one every iteration means one played location.
    # A new iteration starts whenever a player finishes or gives up a location
    # or if all the vikings are dead or if the remainder of them finishes the
    # location.
    # The nested loop updates all the sprites (heroes and their enemies)
    # regularly and refreshes the screen.

    def game_loop
      initialized = false

      loop do 
        # Show loading screen
        paint_loading_screen @app_window

        if ! initialized then
          # First level.
          initialized = true
        else
          
          begin
            level = @world.next_level
          rescue StructuredWorld::NoMoreLevelException
            @log.info "Congratulations! You explored all the world!"
            exit_game
          end
        end

        @give_up = false

        first_attempt = true

        # Repeat one level until it's successfully finished
        begin
          if ! first_attempt then
            paint_loading_screen @app_window
            @world.rewind_location
          end

          result = every_level()

          first_attempt = false
        end while ! result

      end # loop
    end # public method game_loop

    private

    # This method is called from game_loop to manage playing of a level.
    # Returns true if the level was finished successfully, false otherwise.

    def every_level
      level = @world.level
      location = @world.location

      # Display (or not) password of the level
      if FreeVikings::OPTIONS["display_password"] then
        @state = LocationInfoGameState.new(self, level)
      else
        run_location
      end
      
      if FreeVikings::OPTIONS['sound'] then
        @music = nil
        music_file = level.music
        if music_file then
          begin
            @music = Music.new(FreeVikings::MUSIC_DIR+'/'+music_file)
            @music.play
          rescue SDLError => e
            @log.error e.message
            @music = nil
          end
        else
          @log.debug "No music for this level."
        end
      else
        @log.warn "Sound is off."
      end

      @bottompanel = BottomPanel.new location.team

      frames = 0 # auxiliary variable for fps computing
      @frame_rate = 0

      if FreeVikings::OPTIONS['profile'] then
        Profiler__::start_profile
      end

      start_time = Time.now.to_f

      # The frame loop: serve events, update game state
      while (not location.exitted?) and (not @give_up) do
        # Following method serves events, updates sprites, ...
        every_frame(location)

        @app_window.flip

        frames += 1
        s = Time.now.to_f - start_time
        @frame_rate = (frames / s).to_i unless s == 0
      end

      # do what needs to be done at the end of level.
      on_level_end

      if FreeVikings::OPTIONS['profile'] then
        exit # the END block which prints out profiler output will be called
      end

      if (location.team.alive_size < location.team.size) or @give_up
        if @give_up == true then
          @log.info "Game given up. Try once more."
        else
          @log.info "Some viking(s) died. Try once more."

        end

        @give_up = nil

        return false
      elsif location.team.alive_size == location.team.size then
        @log.info "Level completed."
        return true
      else
        # Situation which shouldn't ever occur
        raise FatalError, '*** Really strange situation. Nor the game loop is in it\'s first loop, nor the level completed, no vikings dead. Send a bug report, please.'
      end
    end

    # Called from Game#every_level to update everything and repaint game 
    # window.

    def every_frame(location)
      # Serve events:
      RUDL::EventQueue.get.each do |event|
        @state.serve_event(event, location)
      end

      if FreeVikings::OPTIONS['music'] then
        if @music && (! @music.busy?) then
          @music.play
        end
      end

      unless location.team.active.alive?
        location.team.next
      end

      # nearly all the game state (position of heroes etc.) is updated here
      location.update unless @state.paused?

      if location.talk then
        go_conversation
      end

      if location.story then
        go_story
      end
      
      location.paint(@map_view, location.team.active.center)
      @app_window.blit(@map_view, [0,0])
      
      @state.change_view(@app_window)

      @app_window.blit(@bottompanel.image, [0, WIN_HEIGHT - BottomPanel::HEIGHT])

      if FreeVikings.display_fps? then
        @app_window.fill([0,0,0], [8,8,60,12])
        @app_window.print([10,10], "fps: #{@frame_rate}", [255,255,255])
      end

      if FreeVikings::OPTIONS['delay'] != 0 then
        sleep(FreeVikings::OPTIONS['delay'])
      end
    end

    public

    # This method is called from LocationInfoGameState to start playing.

    def run_location
      @state = PlayingGameState.new self
    end

    private
    def paint_loading_screen(screen)
      screen.fill 0x0000000
      screen.blit(@loading_message, [280,180])
      screen.flip
    end

    # Called from the end of game loop and from Game#exit_game
    private
    def on_level_end
      if FreeVikings::OPTIONS['music'] then
        if @music then
          if @music.busy? then
            @music.fade_out 2000
          end
          @music.destroy
        end
      end
    end

  end # class Game
end # module FreeVikings
