# game.rb
# igneus 28.1.2005

# Objekt Game spravuje stav hry a da se rici, ze je jeho ukolem hru ridit.
# Mj. obsahuje hlavni herni cyklus.

require 'RUDL'

require 'sprite.rb'
require 'viking.rb'
require 'team.rb'
require 'map.rb'
require 'spritemanager.rb'
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
      @map = Map.new("first_loc.xml")

      @manager = SpriteManager.new(@map)

      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @app_window.set_caption('freeVikings')

      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - STATUS_HEIGHT])
      @status_view = RUDL::Surface.new([WIN_WIDTH, STATUS_HEIGHT])

      @face_bg = RUDL::Surface.load_new('face_bg.tga')
      @baleog_face_bw = RUDL::Surface.load_new('baleog_face_unactive.gif')
      @baleog_face = RUDL::Surface.load_new('baleog_face.tga')

      @baleog = Viking.createWarior("Baleog")
      @erik = Viking.createSprinter("Erik")
      @olaf = Viking.createShielder("Olaf")

      @team = Team.new(@erik, @baleog, @olaf)
      @team.each {|v| @manager.add v}

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = PlayingGameState.new(self)
    end # initialize

    def repaint_status
      # vykresleni pozadi pro podobenky vikingu:
      @status_view.fill([60,60,60])
      3.times {|i| @status_view.blit(@face_bg, [i * 2 * VIKING_FACE_SIZE, 0])}
      1.upto(2) {|i| @status_view.blit(@baleog_face_bw, [i * 2 * VIKING_FACE_SIZE, 0])}
      @status_view.blit(@baleog_face, [0,0])
    end

    def game_loop
      fps = 0
      repaint_status
      @app_window.blit(@status_view, [0, WIN_HEIGHT - STATUS_HEIGHT])
      loop do
	# Zpracujeme udalosti:
	if event = RUDL::EventQueue.poll then
	  @state.serve_event(event)
	end # if je udalost

	@map.paint(@map_view, @team.active.center)
	@manager.paint(@map_view, centered_view_rect(@map.background.w, @map.background.h, @map_view.w, @map_view.h, team.active.center))

	@app_window.blit(@map_view, [0,0])
	# nefunguje pod RUDL <= 0.4 (potrebuje pristup k fcim SDL_gfx):
	# @app_window.print([10,10], "fps #{fps / (Timer.ticks / 1000)}", [255,255,255])
	@app_window.flip
	fps += 1
      end # smycky loop
    end # method game_loop

  end
end # module
