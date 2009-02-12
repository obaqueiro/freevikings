# gamestate.rb
# igneus 28.1.2005

require 'RUDL'

module FreeVikings

  class GameState
    # Abstract superclass.
    # GameState instances represent different states of the game.
    # Their task is to process events (keyboard and mouse actions).

    include RUDL
    include RUDL::Constant

    # Argument context is a Game instance - the Game just running.
    def initialize(context)
      @context = context
    end

    # Returns coordinates of the point which is in the center of area
    # shown to the player (usually center of the active viking).
    def view_center
    end

    # Argument surface is a RUDL::Surface. This method is called just
    # after painting the map and all game objects, so that current GameState
    # can modify the displayed image before blitting. It is used e.g. to
    # make the screen darker when the game is paused.
    def change_view(surface)
    end

    # Processes the event (RUDL::Event).
    # Argument location is a Location instance. (Location just played.)
    def serve_event(event, location)
      if event.kind_of? KeyDownEvent
	serve_keydown(event, location)
      elsif event.kind_of? KeyUpEvent
	serve_keyup(event, location)
      else
        raise ArgumentError, "Unsupported event class '#{event.class}'"
      end 
    end

    # Argument location is a Location instance. (Location just played.)
    def serve_keydown(event, location)
      case event.key
      when K_q, K_ESCAPE
        @context.ingame_menu
      when K_F2
	@context.give_up_game
      when K_F3
	@context.app_window.toggle_fullscreen
        FreeVikings::CONFIG['Video']['fullscreen'] = @context.app_window.fullscreen?
      when K_F4
        FreeVikings::CONFIG['Video']['display FPS'] = ! FreeVikings::CONFIG['Video']['display FPS']
      when K_F5
        @context.change_panel_placement
      when K_F9
        if FreeVikings::CONFIG['Development']['magic for developers']
          @context.team.active.destroy
        end
      when K_F10, K_PRINT
        @context.take_screenshot
      when K_F12
        if FreeVikings::CONFIG['Development']['magic for developers']
          # Starts irb in the console=>fV developer can play with the internals
          require 'irb'
          IRB.start(__FILE__)
        end
      end
    end

    # Argument location is a Location instance. (Location just played.)
    def serve_keyup(event, location)
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
      when K_UP
        @context.team.active.up
      when K_DOWN
        @context.team.active.down
      when K_SPACE
	@context.team.active.space_func_on
      when K_d, K_LSHIFT
	@context.team.active.d_func_on
      when K_s
        @context.team.active.s_f_func_on
      when K_f
        @context.team.active.s_f_func_off
      when K_e, K_u, K_INSERT
        @context.team.active.use_item
      when K_p, K_TAB
        @context.bottompanel.browse_inventory!
        @context.pause
      when K_RCTRL, K_PAGEDOWN, K_z
	@context.team.previous
        @context.bottompanel.change_active_viking
      when K_PAGEUP, K_x
	@context.team.next
        @context.bottompanel.change_active_viking
      when K_PLUS, K_KP_PLUS
        Viking.velocity += 10
      when K_MINUS, K_KP_MINUS
        if Viking.velocity > 10 then
          Viking.velocity -= 10
        end
      else
        super(keyevent, location)
      end
    end # private method serve_keydown

    def serve_keyup(keyevent, location)
      case keyevent.key
      when K_LEFT, K_RIGHT
	@context.team.active.stop
      when K_UP, K_DOWN
        @context.team.active.climb_stop
      when K_SPACE
        @context.team.active.space_func_off
      when K_d, K_LSHIFT
        @context.team.active.d_func_off
      end
    end # private method serve_keyup
  end # class PlayingGameState

  class PausedGameState < GameState
    # This state is used when the game is paused. It allows the user to play 
    # with the vikings' inventories.


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

  # State used when a conversation is held.

  class ConversationGameState < GameState
    def paused?
      true
    end

    def serve_keydown(event, location)
      case event.key
      when K_SPACE, K_RETURN
        location.talk_next
        if ! location.talk then
          @context.unpause
        end
      end
    end
  end

  # State used when a story is being told

  class StoryGameState < GameState
    def paused?
      true
    end

    def serve_keydown(event, location)
      case event.key
      when K_SPACE, K_RETURN
        # next frame:
        location.story_next
        if ! location.story then
          @context.unpause
        end
      when K_ESCAPE
        # skip story (stupid or bored player)
        location.story = nil
        @context.unpause
      end
    end
  end

  # This state is used on the beginning of every location.
  # Location password and author is displayed until the player presses a key.

  class LocationInfoGameState < GameState

    # Arguments:
    # context:: a Game object
    # level:: a Level object with the information about 
    #         the Location prepared to play

    def initialize(context, level)
      super(context)
      init_message(level)
    end

    def change_view(surface)
      surface.blit(@level_info_message,
                   [surface.w/2 - @level_info_message.w/2, 140])
    end

    def serve_keydown(event, location)
      @context.run_location
    end

    private

    def init_message(level)
      message = "Password: #{level.password}"
      @level_info_message = FreeVikings::FONTS['default'].create_text_box(120, message, [255,255,255], [0,0,0])
    end
  end # class LocationInfoGameState
end # module
