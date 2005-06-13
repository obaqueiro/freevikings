# game.rb
# igneus 28.1.2005

# Objekt Game spravuje stav hry a da se rici, ze je jeho ukolem hru ridit.
# Mj. obsahuje hlavni herni cyklus.

require 'RUDL'

require 'sprite.rb'
require 'viking.rb'
require 'hero.rb'
require 'duck.rb'
require 'slug.rb'
require 'plasmashooter.rb'
require 'team.rb'
require 'map.rb'
require 'world.rb'
require 'location.rb'
require 'gamestate.rb'

module FreeVikings

  class Game

    include RUDL
    include RUDL::Constant

    VIKING_FACE_SIZE = 60
    WIN_WIDTH = 640
    WIN_HEIGHT = 480
    BOTTOMPANEL_HEIGHT = VIKING_FACE_SIZE

    attr_reader :app_window
    attr_reader :team
    attr_reader :map

    def initialize
      # Zobrazime logo a v oddelenem vlakne zacneme inicialisovat sprajty
      # (nahrava se spousta obrazku, chvili to trva)
      init_app_window
      init_bottompanel_gfx

      # Pokud bylo z prikazove radky vyzadano spusteni urcitych lokaci,
      # vytvorime z nich novy svet. Jinak rozjedeme parbu v implicitnim svete.
      unless FreeVikings::OPTIONS['locations'].empty?
        @world = World.new(*(FreeVikings::OPTIONS['locations']))
      else
        @world = World.new('pyramida_loc.xml',
                           'first_loc.xml',
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

    # This method is called by the GameState when a player presses
    # the give up key (F6 by default).
    # Causes location reloading.
    def give_up_game
	@give_up = true
    end

    # Method 'game_loop' contains two nested loops.
    # In the first one every iteration means one played location.
    # A new iteration starts whenever a player finishes or gives up a location
    # or if all the vikings are dead or if the remainder of them finishes the
    # location.
    # The second loop updates all the sprites (heroes and their enemies)
    # regularly and refreshes the screen.
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
	    @state.serve_event(event)
	  end # if je udalost

	  location.update
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
    def init_app_window
      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @app_window.set_caption('freeVikings')
      logo = RUDL::Surface.load_new GFX_DIR+'/fvlogo.tga'
      @app_window.blit(logo, [(@app_window.w/2) - (logo.w/2), (@app_window.h/3) - (logo.h/2)])
      font = TrueTypeFont.new('fonts/adlibn.ttf', 16)
      @app_window.blit(font.render('freeVikings Copyright (c) 2005 Jakub Pavlik', true, [255,255,255]), [50,250])
      @app_window.blit(font.render('freeVikings come to you as free software under GNU/GPL;', true, [255,255,255]), [50,270])
      @app_window.blit(font.render("They are provided with aim of usability,", true, [255,255,255]), [50,290])
      @app_window.blit(font.render("but with ABSOLUTELY NO WARRANTY.", true, [255,255,255]), [50,310])

      @app_window.flip
    end # init_app_window

    private
    def init_bottompanel_gfx
      @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
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
	@bottompanel_view.blit(@face_bg, [i * 2 * VIKING_FACE_SIZE, 0])
	#if vik.alive? then
        portrait_img = if @team.active == vik && vik.alive? then
                         vik.portrait.active
                       elsif not vik.alive?
                         vik.portrait.kaput
                       else
                         vik.portrait.unactive
                       end
        @bottompanel_view.blit(portrait_img, [i * 2 * VIKING_FACE_SIZE, 0])
        vik.energy.times {|j| @bottompanel_view.blit(@energy_punkt, [i*2*VIKING_FACE_SIZE + VIKING_FACE_SIZE + 2, j*@energy_punkt.h + 3])}
	#end
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

    # Vrati pole vsech sprajtu, ktere se vyskytuji na exitu
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
