# gamestate.rb
# igneus 28.1.2005

# Hra se muze nachazet v nekolika ruznych stavech. Bezne jsou
# stavy GAME, MENU, PAUSE.
# Objekty GameState vykonavaji cinnosti zavisle na stavu.

module FreeVikings

  class GameState

    def initialize(context)
      # Promenna @context je odkazem na objekt Game, jehoz stav objekt
      # GameState vyjadruje a obsluhuje.
      @context = context
    end

    # Obslouzi udalost tak, jak je to v danem stavu potreba.

    def serve_event(event)
      exit if event.is_a? QuitEvent
    end
  end # class GameState

  class PlayingGameState

    def serve_event(event)
      super.serve_event(event)
      if event.is_a? KeyDownEvent
	serve_keydown(event)
      end # if
    end # method serve_event

    private

    def serve_keydown(keyevent)
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
    end # private method serve_keydown

  end # class PlayingGameState
end # module
