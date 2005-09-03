# init.rb
# igneus 14.6.2005

# Graphical initialization.
# When FreeVikings are starting, for a long time nothing happens,
# because Log4r module is doing it's own initialization and some graphics
# are being loaded. Init opens the application window, prints something
# and then starts all the long-lasting stuff.

require 'RUDL'

require 'gameui/gameui.rb'
require 'topmenu.rb'

require 'game.rb'

module FreeVikings

  class Init

    include GameUI
    include GameUI::Menus

    def initialize
      @log = MockLogger.new

      load_logo
      load_font
      open_window
      display_logo

      configure_log4r

      exlog = @log
      @log = Log4r::Logger['init log']
      exlog.each {|l| @log.info l}

      @log.info "Log4r logging mechanisms initialized."

      catch(:game_exit) do
        start_menu
      end
      @log.info "Game exitted."
    end

    private

    # Starts the menu.
    # Does never return, because the menu is ran in an endless loop
    # until it is terminated by unwinding the stack (which is caused by
    # 'throw :game_exit' from inside TopMenu).

    def start_menu
      @log.info "Starting game menu."

      menu = TopMenu.new(@window)

      ActionButton.new(menu, "Start Game", Proc.new {start_game})

      graphics = Menu.new(menu, "Graphics", nil, menu.text_renderer)
      ChooseButton.new(graphics, "Display fps", ["yes", "no"])
      ChooseButton.new(graphics, "Mode", ["window", "fullscreen"])
      QuitButton.new(graphics)

      QuitButton.new(menu, QuitButton::QUIT)

      # The endless 'menu loop'.
      # Is ended from inside TopMenu by unwinding the stack.
      # When does this happen? When you choose 'Yes' in the 'Quit - yes or no'
      # dialog.
      loop do
        catch(:return_to_menu) do
          clear_screen
          menu.run
        end
      end
    end

    def start_game
      @log.info "Starting the game."
      Game.new(@window).game_loop
      # Game#game_loop never returns, because exit is called inside.
    end

    def load_logo
      @log.info "Loading the freeVikings logo."
      @logo = RUDL::Surface.load_new GFX_DIR+'/fvlogo.tga'
    end

    def load_font
      @log.info "Loading default font."
      adlibn_ttf = RUDL::TrueTypeFont.new('fonts/adlibn.ttf', 16)
      @font = FreeVikings::FONTS['default'] = TextRenderer.new(adlibn_ttf)
    end

    def open_window
      @log.info "Initializing the game window."
      @window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @window.set_caption('freeVikings')
      @window.toggle_fullscreen if FreeVikings::OPTIONS['fullscreen']
    end

    def display_logo
      @window.blit(@logo, [(@window.w/2) - (@logo.w/2), (@window.h/3) - (@logo.h/2)])

      license_message = \
      "freeVikings Copyright (c) 2005 Jakub Pavlik\n" \
      "freeVikings come to you as free software under GNU/GPL; " \
      "They are provided with aim of usability, " \
      "but with\nABSOLUTELY NO WARRANTY."

      license_text_box = @font.create_text_box(WIN_WIDTH - 100, 
                                                     license_message)
      @window.blit(license_text_box, [50,310])

      @window.flip
    end

    def configure_log4r
      require 'log4rsetupload'
    end

    def clear_screen
      @window.fill [0,0,0]
    end
  end # class Init

  class MockLogger < Array
    alias_method :info, :push
  end
end # module FreeVikings
