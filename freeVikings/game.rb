# game.rb
# igneus 28.1.2005

# Objekt Game spravuje stav hry a da se rici, ze je jeho ukolem hru ridit.
# Mj. obsahuje hlavni herni cyklus.

require 'RUDL'

require 'sprite.rb'
require 'viking.rb'
require 'map.rb'
require 'spritemanager.rb'
require 'gamestate.rb'

module FreeVikings

  class Game

    include RUDL
    include RUDL::Constant

    WIN_WIDTH = 300
    WIN_HEIGHT = 300

    attr_reader :viking
    attr_reader :map

    def initialize
      @map = Map.new("hopsy_loc.xml")

      @manager = SpriteManager.new(@map)

      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])

      @baleog = Viking.new
      @baleog.name = "Baleog"
      @manager.add @baleog

      @viking = @baleog

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = PlayingGameState.new(self)
    end # initialize

    def game_loop
      loop do
	# Zpracujeme udalosti:
	if event = RUDL::EventQueue.poll then
	  @state.serve_event(event)
	end # if je udalost

	@map.paint(@app_window, viking.center)
	@manager.paint(@app_window, centered_view_rect(@map.background.w, @map.background.h, @app_window.w, @app_window.h, viking.center))
	@app_window.flip
      end # smycky loop
    end # method game_loop

  end
end # module
