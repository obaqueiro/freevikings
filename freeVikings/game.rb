# game.rb
# igneus 28.1.2005

# Objekt Game spravuje stav hry a da se rici, ze je jeho ukolem hru ridit.
# Mj. obsahuje hlavni herni cyklus.

require 'RUDL'

require 'sprite.rb'
require 'viking.rb'
require 'map.rb'
require 'spritemanager.rb'

module FreeVikings

  class Game

    include RUDL
    include RUDL::Constant

    WIN_WIDTH = 300
    WIN_HEIGHT = 300

    def initialize
      @map = Map.new("first_loc_beta.xml")

      @manager = SpriteManager.new(@map)

      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])

      @baleog = Viking.new
      @baleog.name = "Baleog"
      @manager.add @baleog
    end # initialize

    def game_loop
      loop do
	# Zpracujeme udalosti:
	if event = RUDL::EventQueue.poll then
	  # Ukonceni hry:
	  exit if event.is_a? QuitEvent
	  # Stisk klavesy:
	  if event.is_a?(KeyDownEvent)
	    case event.key
	      # Smerove klavesy:
	    when K_LEFT
	      @baleog.move_left
	    when K_RIGHT
	      @baleog.move_right
	      # Funkcni klavesy:
	    when K_SPACE
	    when K_TAB
	    when K_s
	    when K_f
	    end # case
	  elsif event.is_a?(KeyUpEvent)
	    @baleog.stop
	  end # if elsif co je to za udalost?
	end # if je udalost
	@map.paint(@app_window, [@baleog.left, @baleog.top])
	@manager.paint(@app_window, centered_view_rect(@map.background.w, @map.background.h, @app_window.w, @app_window.h, @baleog.center))
	@app_window.flip
      end # smycky loop
    end # method game_loop

  end
end # module
