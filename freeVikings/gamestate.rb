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
    end

    # Obslouzi udalost tak, jak je to v danem stavu potreba.

    def serve_event(event)
      end_game if event.is_a? QuitEvent
    end

    # Zajistime potomkum dostupnost predkovy metody:
    alias :parent_serve_event :serve_event

    private

    def end_game
      puts "Ending the game."
      exit
    end # private method end_game

  end # class GameState


  class PlayingGameState < GameState

    def initialize(context)
      super(context)
    end

    def serve_event(event, location)
      parent_serve_event(event)
      if event.is_a? KeyDownEvent
	serve_keydown(event, location)
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

    def serve_keydown(keyevent, location)
      case keyevent.key
	# Smerove klavesy:
      when K_LEFT
	@context.team.active.move_left
      when K_RIGHT
	@context.team.active.move_right
	# Funkcni klavesy:
      when K_SPACE
	@context.team.active.space_func_on
      when K_d
	@context.team.active.d_func_on
      when K_s
        location.active_objects_on_rect(@context.team.active.rect).each { |o| o.activate }
      when K_f
        location.active_objects_on_rect(@context.team.active.rect).each { |o| o.deactivate }
	# Specialni klavesy:
      when K_RCTRL
	@context.team.last
      when K_PAGEUP
	@context.team.next
      when K_q, K_ESCAPE
        end_game
      when K_F3
	@context.app_window.toggle_fullscreen
      when K_F4
        FreeVikings::OPTIONS['display_fps'] = ! FreeVikings::OPTIONS['display_fps']
      when K_F6
	@context.give_up_game
      end # case
    end # private method serve_keydown

    def serve_keyup(keyevent)
      case keyevent.key
      when K_LEFT, K_RIGHT
	@context.team.active.stop
      when K_SPACE
        @context.team.active.space_func_off
      when K_d
        @context.team.active.d_func_off
      end
    end # private method serve_keyup

  end # class PlayingGameState
end # module
