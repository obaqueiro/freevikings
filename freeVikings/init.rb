# init.rb
# igneus 14.6.2005

# Graphical initialization.
# When FreeVikings are starting, for a long time nothing happens,
# because Log4r module is doing it's own initialization and some graphics
# are being loaded. Init opens the application window, prints something
# and then starts all the long-lasting stuff.

require 'RUDL'

require 'game.rb'

module FreeVikings

  class Init

    def initialize
      FreeVikings.runlevel = 'INITIALIZATION'

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

      start_game
    end

    private

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
      @font = FreeVikings::FONTS['big'] = RUDL::TrueTypeFont.new('fonts/adlibn.ttf', 16)
    end

    def open_window
      @log.info "Initializing the game window."
      @window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @window.set_caption('freeVikings')
      @window.toggle_fullscreen if FreeVikings::OPTIONS['fullscreen']
    end

    def display_logo
      @window.blit(@logo, [(@window.w/2) - (@logo.w/2), (@window.h/3) - (@logo.h/2)])
      @window.blit(@font.render('freeVikings Copyright (c) 2005 Jakub Pavlik', true, [255,255,255]), [50,250])
      @window.blit(@font.render('freeVikings come to you as free software under GNU/GPL;', true, [255,255,255]), [50,270])
      @window.blit(@font.render("They are provided with aim of usability,", true, [255,255,255]), [50,290])
      @window.blit(@font.render("but with ABSOLUTELY NO WARRANTY.", true, [255,255,255]), [50,310])

      @window.flip
    end

    def configure_log4r
      require 'log4rsetupload'
    end
  end # class Init

  class MockLogger < Array
    alias_method :info, :push
  end
end # module FreeVikings
