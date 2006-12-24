# gamestate.rb
# igneus 28.1.2005

# Hra se muze nachazet v nekolika ruznych stavech. Bezne jsou
# stavy GAME, MENU, PAUSE.
# Objekty GameState vykonavaji cinnosti zavisle na stavu.

require 'RUDL'

module FreeVikings

=begin
= GameState
=end

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

=begin
GameState#change_view(surface)
Changes the location view according to the state.
=end

    def change_view(surface)
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
        FreeVikings::OPTIONS['fullscreen'] = @context.app_window.fullscreen?
      when K_F4
        FreeVikings::OPTIONS['display_fps'] = ! FreeVikings::OPTIONS['display_fps']
      when K_F2
	@context.give_up_game
      when K_F12
        # Starts irb in the console => fV developer can play with the internals
        require 'irb'
        IRB.start(__FILE__)
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
      @context.exit_game
    end # private method end_game

  end # class GameState


  class PlayingGameState < GameState

    def initialize(context)
      super context
      # @context.bottompanel
    end

    def view_center
      # stred nahledu na mapu by mel byt ve stredu obrazku
      # hlavniho hrdiny
      @context.team.active.center
    end

    private

    def serve_keydown(keyevent, location)
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
      when K_s, K_UP
        location.active_objects_on_rect(@context.team.active.rect).each { |o| o.activate }
      when K_f, K_DOWN
        location.active_objects_on_rect(@context.team.active.rect).each { |o| o.deactivate }
      when K_e, K_u
        @context.team.active.use_item
      when K_p, K_TAB
        @context.bottompanel.browse_inventory!
        @context.pause
      when K_RCTRL, K_PAGEDOWN
	@context.team.previous
      when K_PAGEUP
	@context.team.next
      else
        super(keyevent, location)
      end
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

=begin
= PausedGameState
This state is used when the game is paused. It allows the user to play with
the vikings' inventories.
=end

  class PausedGameState < GameState

    def initialize(context)
      super context
      init_mask_surface
    end

    def change_view(surface)
      surface.blit @mask_surface, [0,0]
    end

    def serve_keydown(event, location)
      # !!! Don't add call to super here; it was here, now it is in the
      # !!! 'else' branch of case. And it's right so.
      case event.key
      when K_p, K_TAB
        if bottompanel.inventory_browsing? then
          bottompanel.go_normal!
          @context.unpause
        end
      when K_ESCAPE
        if bottompanel.inventory_browsing? or
            bottompanel.items_exchange? then
          bottompanel.go_normal!
          @context.unpause
        end
      when K_SPACE
        if bottompanel.items_exchange?
          bottompanel.browse_inventory!
        elsif bottompanel.inventory_browsing?
          bottompanel.exchange_items!
        end
      when K_UP, K_DOWN, K_LEFT, K_RIGHT, K_DELETE
        begin
          case event.key
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
          # Nothing bad for us. The player has just tried to move 
          # the selection in the inventory onto a slot which doesn't have 
          # any item inside. Ignore it.
        end
      else
        super(event, location)
      end
    end

    def paused?
      true
    end

    private

    def bottompanel
      @context.bottompanel
    end

    # Initializes the grey surface which is used to change the game screen
    # when the game is paused

    def init_mask_surface
      @mask_surface = RUDL::Surface.new [FreeVikings::WIN_WIDTH, 
                                         FreeVikings::WIN_HEIGHT]
      grey = [10, 10, 10]
      @mask_surface.fill grey
      @mask_surface.set_colorkey grey
      box = FreeVikings::FONTS['default'].create_text_box(120, "PAUSED...")
      @mask_surface.blit box, [@mask_surface.w/2 - box.w/2,
                               @mask_surface.h/2 - box.h/2 - 60]
    end
  end # class PausedGameState


=begin
= LocationInfoGameState
This state is used on the beginning of every location.
Location password and author is displayed until the player presses a key.
=end

  class LocationInfoGameState < GameState

=begin
--- LocationInfoGameState.new(context, level)
Arguments:
* ((|context|)) - a (({Game})) object
* ((|level|)) - a (({Level})) object with the information about 
  the (({Location})) prepared to play
=end

    def initialize(context, level)
      super(context)
      init_message(level)
    end

    def change_view(surface)
      surface.blit(@level_info_message,
                   [surface.w/2 - @level_info_message.w/2, 140])
    end

    def serve_keydown(event, location)
      @context.run_location location
    end

    private

    def init_message(level)
      message = "Password: #{level.password}"
      @level_info_message = FreeVikings::FONTS['default'].create_text_box(120, message)
    end
  end # class LocationInfoGameState

=begin
= AllLocationsFinishedGameState
A (({Game})) state used when the player successfully explores the last
(({Location})).
=end

  class AllLocationsFinishedGameState < GameState

    def initialize(context)
      super(context)
      init_message
    end

    def change_view(surface)
      surface.blit(@message,
                   [surface.w/2 - @message.w/2, 50])
    end

    def serve_keydown(event, location)
      @context.exit_game
    end

    private

    def init_message
      text = "Erik, Baleog and Olaf have forgotten Tomator. " \
      "They were just walking, clobbering monsters and " \
      "exploring foreign sides. " \
      "Suddenly something like a thunder sounded and they " \
      "all fainted. Where did they wake up?\n" \
      "Don't forget to download the next version of freeVikings!" \
      "\n|\nhttp://freevikings.wz.cz\n|\n" \
      "All comments, bug reports, ideas etc. are appreciated." \
      "\n|\nseverus@post.cz"

      @message = FreeVikings::FONTS['default'].create_text_box(FreeVikings::WIN_WIDTH-100, text)
    end
  end
end # module
