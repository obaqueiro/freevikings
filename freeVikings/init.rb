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
require 'passwordedit.rb'

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
      # The stack's been unwinded. The user has exited freeVikings.
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

      start_menu = Menu.new(menu, "Start Game", nil, nil)
      ActionButton.new(start_menu, "New Game", Proc.new {
                         @log.info "Starting new game."
                         Game.new(@window).game_loop
                       })
      PasswordEdit.new(start_menu, "Password", FreeVikings::OPTIONS['startpassword'], Proc.new {
                         @log.info "Starting the game with password '#{FreeVikings::OPTIONS['startpassword']}'."
                         Game.new(@window, FreeVikings::OPTIONS['startpassword']).game_loop
                       })
      QuitButton.new(start_menu)

      graphics_menu = Menu.new(menu, "Graphics", nil, nil)
      FVConfiguratorButton.new(graphics_menu, "Display fps", "display_fps", {"yes" => true, "no" => false})
      QuitButton.new(graphics_menu)

      QuitButton.new(menu, QuitButton::QUIT)

      # The endless 'menu loop'.
      # Is ended from inside TopMenu by unwinding the stack.
      # When does this happen? When you choose 'Yes' in the 'Quit - yes or no'
      # dialog.
      loop do
        # Here unwinding the stack is used by Game#exit_game to say
        # 'hey, menu, I've finished my work, speak with the user for a while'.
        # Don't forget the same technique, unwinding the stack, (but with
        # another symbol) is used to exit the menu and the entire program.
        catch(:return_to_menu) do
          clear_screen
          menu.run
        end
      end
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
