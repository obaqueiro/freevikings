# game.rb
# igneus 28.1.2005

# Objekt Game spravuje stav hry a da se rici, ze je jeho ukolem hru ridit.
# Mj. obsahuje hlavni herni cyklus.

require 'RUDL'

require 'sprite.rb'
require 'viking.rb'
require 'duck.rb'
require 'team.rb'
require 'map.rb'
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
      ObjectSpace.define_finalizer(self, Proc.new {finalize})

      strategy = XMLMapLoadStrategy.new("first_loc.xml")

      @location = Location.new(strategy)

      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @app_window.set_caption('freeVikings')

      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - STATUS_HEIGHT])
      @status_view = RUDL::Surface.new([WIN_WIDTH, STATUS_HEIGHT])

      @face_bg = RUDL::Surface.load_new('face_bg.tga')
      @baleog_face_bw = RUDL::Surface.load_new('baleog_face_unactive.gif')
      @baleog_face = RUDL::Surface.load_new('baleog_face.tga')
      @dead_face = RUDL::Surface.load_new('dead_face.png')
      @energy_punkt = RUDL::Surface.load_new('energypunkt.tga')

      @baleog = Viking.createWarior("Baleog")
      @erik = Viking.createSprinter("Erik")
      @olaf = Viking.createShielder("Olaf")

      @team = Team.new(@erik, @baleog, @olaf)
      @team.each {|v| @location.add_sprite v}

      @duck = Duck.new
      @location.add_sprite @duck

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = PlayingGameState.new(self)
    end # initialize

    def finalize
      puts "Destroying the application window, ending the game."
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
    end

    def game_loop
      fps = 0
      loop do
	# Zpracujeme udalosti:
	if event = RUDL::EventQueue.poll then
	  @state.serve_event(event)
	end # if je udalost

	@location.update
	@location.paint(@map_view, @team.active.center)
	@app_window.blit(@map_view, [0,0])
	# nefunguje pod RUDL <= 0.4 (potrebuje pristup k fcim SDL_gfx):
	# @app_window.print([10,10], "fps #{fps / (Timer.ticks / 1000)}", [255,255,255])
	puts "FPS: #{fps / (Timer.ticks / 1000)}"
	repaint_status
	@app_window.blit(@status_view, [0, WIN_HEIGHT - STATUS_HEIGHT])

	@app_window.flip
	fps += 1
      end # smycky loop
    end # method game_loop

  end
end # module
