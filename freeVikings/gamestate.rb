# gamestate.rb
# igneus 28.1.2005

# Hra se muze nachazet v nekolika ruznych stavech. Bezne jsou
# stavy GAME, MENU, PAUSE.
# Objekty GameState vykonavaji cinnosti zavisle na stavu.

require 'RUDL'

module FreeVikings


  class GameState

    include RUDL
    include RUDL::Constant

    def initialize(context)
      # Promenna @context je odkazem na objekt Game, jehoz stav objekt
      # GameState vyjadruje a obsluhuje.
      @context = context
    end

    # Vrati souradnice bodu, na ktery by se melo centrovat zobrazeni

    def view_center
      [0,0]
    end

    # Obslouzi udalost tak, jak je to v danem stavu potreba.

    def serve_event(event)
      end_game if event.is_a? QuitEvent
    end

    # Zajistime potomkum dostupnost predkovy metody:
    alias :parent_serve_event :serve_event
  end # class GameState


  class PlayingGameState < GameState

    def initialize(context)
      super(context)
    end

    def serve_event(event)
      parent_serve_event(event)
      if event.is_a? KeyDownEvent
	serve_keydown(event)
      elsif event.is_a? KeyUpEvent
	serve_keyup(event)
      end # if
    end # method serve_event

    def view_center
      # stred nahledu na mapu by mel byt ve stredu obrazku
      # hlavniho hrdiny
      @context.team.active.center
    end

    private

    def serve_keydown(keyevent)
      case keyevent.key
	# Smerove klavesy:
      when K_LEFT
	@context.team.active.move_left
      when K_RIGHT
	@context.team.active.move_right
	# Funkcni klavesy:
      when K_SPACE
	@context.team.active.space_func
      when K_TAB
      when K_s
      when K_f
	# Specialni klavesy:
      when K_RCTRL
	@context.team.last
      when K_PAGEUP
	@context.team.next
      when K_F3
	@context.app_window.toggle_fullscreen
      when K_q
	end_game if RUDL::Key.modifiers && K_LCTRL
      end # case
    end # private method serve_keydown

    def serve_keyup(keyevent)
      case keyevent.key
      when K_LEFT, K_RIGHT
	@context.team.active.stop
      end
    end # private method serve_keyup

    def end_game
      @context.finalize
    end # private method end_game
  end # class PlayingGameState
end # module
