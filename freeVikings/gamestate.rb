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

    def serve_event(event, location)
      if event.is_a? QuitEvent then
        end_game
      end

      if event.is_a? KeyDownEvent
	serve_keydown(event, location)
      elsif event.is_a? KeyUpEvent
	serve_keyup(event, location)
      elsif event.is_a? MouseButtonDownEvent
        serve_mouseclick(event, location)
      end # if
    end

    def serve_keydown(event, location)
      case event.key
      when K_q, K_ESCAPE
        end_game
      when K_F3
	@context.app_window.toggle_fullscreen
      when K_F4
        FreeVikings::OPTIONS['display_fps'] = ! FreeVikings::OPTIONS['display_fps']
      when K_F2
	@context.give_up_game
      end
    end

    def serve_keyup(event, location)
    end

    def serve_mouseclick(event, location)
    end

    def paused?
      false
    end

    private

    def end_game
      Log4r::Logger['init log'].info "Ending the game."
      exit
    end # private method end_game

  end # class GameState


  class PlayingGameState < GameState

    def initialize(context)
      super context
      @context.bottompanel
    end

    def view_center
      # stred nahledu na mapu by mel byt ve stredu obrazku
      # hlavniho hrdiny
      @context.team.active.center
    end

    private

    def serve_keydown(keyevent, location)
      super(keyevent, location)

      case keyevent.key
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
      when K_e, K_u
        @context.team.active.use_item
      when K_p, K_TAB
        @context.bottompanel.set_browse_inventory
        @context.pause
      when K_RCTRL, K_PAGEDOWN
	@context.team.previous
      when K_PAGEUP
	@context.team.next
      end # case
    end # private method serve_keydown

    def serve_keyup(keyevent, location)
      case keyevent.key
      when K_LEFT, K_RIGHT
	@context.team.active.stop
      when K_SPACE
        @context.team.active.space_func_off
      when K_d
        @context.team.active.d_func_off
      end
    end # private method serve_keyup

    def serve_mouseclick(event, location)
      if y_in_bottompanel(event.pos[1]) then
        Log4r::Logger['freeVikings log'].info "Mouse click in the bottompanel area."
        game_screen_height = Game::WIN_HEIGHT - BottomPanel::HEIGHT
        pos_in_the_panel = [event.pos[0], event.pos[1] - game_screen_height]
        @context.bottompanel.mouseclick(pos_in_the_panel)
      end
    end

    def y_in_bottompanel(y)
      if y >= FreeVikings::WIN_HEIGHT - BottomPanel::HEIGHT then
        return true
      else
        return false
      end
    end
  end # class PlayingGameState



  class PausedGameState < GameState

    def initialize(context)
      super context
    end

    def serve_keydown(event, location)

      super(event, location)

      begin
        # The following lines are a bit tricky.
        # They move the selection box like the arrow keys order.
        # To understand them you must know that the items from the inventory
        # are displayed in four small windows on the bottompanel in this order:
        # 0 1
        # 2 3
        # The selection box highlights the item with index 
        # anInventory.active_index. This attribute is changed to move 
        # the selection box.
        case event.key
        when K_p, K_TAB
          bp_state = bottompanel.set_browse_inventory
          if bp_state.normal? then
            @context.unpause
          end
        when K_SPACE
          bottompanel.set_items_exchange
        when K_UP
          bottompanel.up
        when K_DOWN
          bottompanel.down
        when K_LEFT
          bottompanel.left
        when K_RIGHT
          bottompanel.right
        when K_DELETE
          bottompanel.delete_active_item
        end
      rescue Inventory::EmptySlotRequiredException
        # This exception doesn't mean anything bad for us. The player
        # has just tried to move the selection in the inventory
        # onto a slot which doesn't have any item inside.
      end
    end

    def paused?
      true
    end

    private

    def bottompanel
      @context.bottompanel
    end
  end # class PausedGameState
end # module
