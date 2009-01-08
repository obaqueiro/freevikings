# initfv.rb
# igneus 14.6.2005

# Graphical initialization.
# When FreeVikings are starting, for a long time nothing happens,
# because Log4r module is doing it's own initialization and some graphics
# are being loaded. Init opens the application window, prints something
# and then starts all the long-lasting stuff.

require 'gameui/all'

require 'rudlmore.rb'

require 'topmenu.rb'
require 'passwordedit.rb'

require 'game.rb'

module FreeVikings

  class Init

    include GameUI
    include GameUI::Menus

    def initialize
      @log = Log4r::Logger['init log']

      load_logo
      load_font
      open_window
      display_logo

      begin
        catch(:game_exit) do
          start_menu
        end
        # The stack's been unwinded. The user has exited freeVikings.
        @log.info "Game exitted."
      rescue => e
        @log.info "Uncaught exception detected. Please, send the crash log file 'log/crash.log' together with a detailed description what you were doing when the game crashed to <severus@post.cz>. Your bug report will help me a lot."
        @log.fatal "Uncaught exception (#{e.class})" + e.message
        raise
      end
    end

    private

    # Starts the menu.
    # Does never return, because the menu is ran in an endless loop
    # until it is terminated by unwinding the stack (which is caused by
    # 'throw :game_exit' from inside TopMenu).
    #
    # If menu is skipped by a commandline option, starts the game directly.
    def start_menu
      @log.info "Starting game menu."

      if FreeVikings::CONFIG['Video']['menu'] == false then
        @log.info "Skipping menu as requested; starting the game directly."
        catch :return_to_menu do
          if password = FreeVikings::CONFIG['Game']['start password'] then
            Game.new(@window, password).game_loop
          else
            Game.new(@window).game_loop
          end
        end
        @log.info "Game ended; skipping menu -> exiting."
      else
        # Top menu
        top_menu = TopMenu.new(@window) do |menu|

          # Submenu: Start Game
          Menu.new(menu, "Start Game") do |start_menu|
            ActionButton.new(start_menu, "New Game", Proc.new {
                               @log.info "Starting new game."
                               Game.new(@window).game_loop
                             })
            PasswordEdit.new(start_menu, 
                             "Password", 
                             FreeVikings::CONFIG['Game']['start password'], 
                             Proc.new {
                               @log.info "Starting the game with password "\
                               "'#{FreeVikings::CONFIG['Game']['start password']}'."
                               Game.new(@window, FreeVikings::CONFIG['Game']['start password']).game_loop
                             })
            # SubSubmenu: Select Level (nifty feature for developers)
            if FreeVikings::VERSION == 'DEV' && ARGV[0] == 'megahIte' then
              Menu.new(start_menu, "SELECT LEVEL", nil, nil) do |sellevel_menu|
                StructuredWorld.new(FreeVikings::CONFIG['Files']['levels'][0]).levels.each do |l|
                  ActionButton.new(sellevel_menu, l.title, Proc.new {
                                     @log.info "Starting the game with password '#{l.password}'."
                                     Game.new(@window, l.password).game_loop
                                   })
                end
                QuitButton.new(sellevel_menu)
              end
            end

            QuitButton.new(start_menu)
          end
          
          # Submenu: Graphics
          Menu.new(menu, "Graphics", nil,nil,nil,nil, 300) do |graphics_menu|
          
            FVConfiguratorButton.new(graphics_menu,
                                     "Mode", 
                                     "Video/fullscreen",
                                     {"fullscreen" => true, 
                                       "window" => false},
                                     Proc.new {|old,new|
                                       @window.toggle_fullscreen
                                     })
            # DisplayModeChooseButton.new(graphics_menu, @window)
            FVConfiguratorButton.new(graphics_menu, 
                                     "Display fps", 
                                     "Video/display FPS", 
                                     {"yes" => true, "no" => false})
            FVConfiguratorButton.new(graphics_menu, 
                                     "Progressbar", 
                                     "Video/loading progressbar", 
                                     {"on" => true, "off" => false})
            FVConfiguratorButton.new(graphics_menu,
                                     "Panel placement",
                                     'Video/panel placement',
                                     {'bottom' => :bottom, 'top' => :top,
                                       'left' => :left, 'right' => :right})
            QuitButton.new(graphics_menu)
          end

          # Submenu: Sound
          Menu.new(menu, "Sound") do |sound_menu|

            FVConfiguratorButton.new(sound_menu, "Level music", 'Audio/music enabled', 
                                     {'on' => true, 'off' => false})
            QuitButton.new(sound_menu)
          end

          # Submenu: Credits
          Credits.new(menu, [['Jakub Pavlik', 'programming, graphics, levels'],
                             ['Ingo Fulfs', 'graphics, music']])
          
          QuitButton.new(menu, QuitButton::QUIT)
        end

        # The endless 'menu loop'.
        # Is ended from inside TopMenu by unwinding the stack.
        # When does this happen? When you choose 'Yes' 
        # in the 'Quit - yes or no' dialog.
        loop do
          # Here unwinding the stack is used by Game#exit_game to say
          # 'hey, menu, I've finished my work, speak with the user 
          # for a while'.
          # Don't forget the same technique, unwinding the stack, (but with
          # another symbol) is used to exit the menu and the entire program.
          catch(:return_to_menu) do
            clear_screen
            begin
              top_menu.run
            rescue Menu::QuitEventAcceptedException
              # User closed the window; let's terminate...
              @log.info "Game terminated by user."
              exit
            end
          end
        end
      end
    end

    def load_logo
      @log.info "Loading the freeVikings logo."
      @logo = RUDL::Surface.load_new GFX_DIR+'/fvlogo_new.tga'
    end

    def load_font
      @log.info "Loading default font."
      adlibn_ttf = RUDL::TrueTypeFont.new('fonts/adlibn.ttf', 16)
      @font = FreeVikings::FONTS['default'] = TextRenderer.new(adlibn_ttf)
    end

    def open_window
      @log.info "Initializing the game window."
      @window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @window.set_caption(FreeVikings::WIN_CAPTION)
      @window.toggle_fullscreen if FreeVikings::CONFIG['Video']['fullscreen']
    end

    def display_logo
      @window.blit(@logo, [(@window.w/2) - (@logo.w/2), (@window.h/3) - (@logo.h/2)])

      license_message = \
      "freeVikings v#{FreeVikings::VERSION}\n"  \
      "Copyright (c) 2005 Jakub Pavlik\n" \
      "freeVikings come to you as free software under GNU/GPL. " \
      "They are provided with aim of usability, " \
      "but with\nABSOLUTELY NO WARRANTY."

      license_text_box = @font.create_text_box(WIN_WIDTH - 100, 
                                                     license_message)
      @window.blit(license_text_box, [50,310])

      @window.flip
    end

    def clear_screen
      @window.fill [0,0,0]
    end
  end # class Init
end # module FreeVikings
