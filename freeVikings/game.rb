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
    STATUS_HEIGHT = VIKING_FACE_SIZE

    attr_reader :app_window
    attr_reader :team
    attr_reader :map

    def initialize
      # Zobrazime logo a v oddelenem vlakne zacneme inicialisovat sprajty
      # (nahrava se spousta obrazku, chvili to trva)
      init_app_window
      image_loader = Thread.new {init_sprites_and_images}

      @world = World.new

      # Surfaces, ktere se pouzivaji k sestaveni zobrazeni nahledu hraci plochy
      # a stavoveho radku s podobiznami vikingu
      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - STATUS_HEIGHT])
      @status_view = RUDL::Surface.new([WIN_WIDTH, STATUS_HEIGHT])

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = PlayingGameState.new(self)

      image_loader.join
    end # initialize

    def init_app_window
      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @app_window.set_caption('freeVikings')
      logo = RUDL::Surface.load_new 'fvlogo.tga'
      @app_window.blit(logo, [@app_window.w/2-logo.w/2,@app_window.h/2-logo.h/2])
      @app_window.flip
    end # init_app_window

    def init_sprites_and_images
      @face_bg = RUDL::Surface.load_new('face_bg.tga')
      @baleog_face_bw = RUDL::Surface.load_new('erik_face_unactive.gif')
      @baleog_face = RUDL::Surface.load_new('erik_face.tga')
      @dead_face = RUDL::Surface.load_new('dead_face.png')
      @energy_punkt = RUDL::Surface.load_new('energypunkt.tga')

      @baleog = Viking.createWarior("Baleog")
      @erik = Viking.createSprinter("Erik")
      @olaf = Viking.createShielder("Olaf")

    end # init_display

    def finalize
      puts "Ending the game."
      exit
    end # finalize

    def repaint_status
      # vybarveni pozadi pro podobenky vikingu:
      @status_view.fill([60,60,60])
      i = 0
      @team.each { |vik|
	@status_view.blit(@face_bg, [i * 2 * VIKING_FACE_SIZE, 0])
	if vik.alive? then
	  if @team.active == vik then
	    @status_view.blit(@baleog_face, [i * 2 * VIKING_FACE_SIZE, 0])
	  else
	    @status_view.blit(@baleog_face_bw, [i * 2 * VIKING_FACE_SIZE, 0])
	  end
	  vik.energy.times {|j| @status_view.blit(@energy_punkt, [i*2*VIKING_FACE_SIZE + VIKING_FACE_SIZE + 2, j*@energy_punkt.h + 3])}
	end
	unless vik.alive?
	  @status_view.blit(@dead_face, [i * 2 * VIKING_FACE_SIZE, 0])
	end
	i += 1
      }
    end # repaint_status

    def game_over?
      nil
    end # game_over?

    def game_loop
      while not self.game_over? do
	@world.next_location
	location = @world.location

	@team = Team.new(@erik, @baleog, @olaf)
	@team.each { |v|
	  v.extend Hero # vsechny vikingy oznacime jako hrdiny
	  location.add_sprite v }

	frames = 0 # pomocna promenna k vypoctu fps
	while not location.exited? do

	  # Zpracujeme udalosti:
	  if event = RUDL::EventQueue.poll then
	    @state.serve_event(event)
	  end # if je udalost

	  location.update
	  location.paint(@map_view, @team.active.center)
	  @app_window.blit(@map_view, [0,0])

	  # Nasledujici nefunguje pod RUDL <= 0.4 (potrebuje pristup k fcim 
	  # SDL_gfx):
	  # @app_window.print([10,10], "fps #{frames / (Timer.ticks / 1000)}", [255,255,255])
	  # Nasledujici radek - mimochodem opsany z oficialnich prikladu
	  # k RUDL 1.8, pod RUDL 1.4 pusobi beznadejne zatvrdnuti programu
	  # po ukonceni volanim exit.
	  # puts "FPS: #{frames / (Timer.ticks / 1000)}"

	  repaint_status
	  @app_window.blit(@status_view, [0, WIN_HEIGHT - STATUS_HEIGHT])

	  @app_window.flip
	  frames += 1
	  
	end # while not location.exited?
      end # while not self.game_over?
    end # game_loop

  end
end # module
