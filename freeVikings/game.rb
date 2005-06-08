# game.rb
# igneus 28.1.2005

# Objekt Game spravuje stav hry a da se rici, ze je jeho ukolem hru ridit.
# Mj. obsahuje hlavni herni cyklus.

require 'RUDL'

require 'sprite.rb'
require 'viking.rb'
require 'hero.rb'
require 'duck.rb'
require 'slug.rb'
require 'plasmashooter.rb'
require 'team.rb'
require 'map.rb'
require 'world.rb'
require 'location.rb'
require 'gamestate.rb'

module FreeVikings

  class Game

    include RUDL
    include RUDL::Constant

    VIKING_FACE_SIZE = 60
    WIN_WIDTH = 640
    WIN_HEIGHT = 480
    STATUS_HEIGHT = VIKING_FACE_SIZE

    attr_reader :app_window
    attr_reader :team
    attr_reader :map

    def initialize
      # Zobrazime logo a v oddelenem vlakne zacneme inicialisovat sprajty
      # (nahrava se spousta obrazku, chvili to trva)
      init_app_window
      image_loader = Thread.new {init_sprites_and_images}

      # Pokud bylo z prikazove radky vyzadano spusteni urcitych lokaci,
      # vytvorime z nich novy svet. Jinak rozjedeme parbu v implicitnim svete.
      unless FreeVikings::OPTIONS['locations'].empty?
        @world = World.new(*(FreeVikings::OPTIONS['locations']))
      else
        @world = World.new('pyramida_loc.xml',
                           'first_loc.xml',
                           'hopsy_loc.xml')
      end

      # Surfaces, ktere se pouzivaji k sestaveni zobrazeni nahledu hraci plochy
      # a stavoveho radku s podobiznami vikingu
      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - STATUS_HEIGHT])
      @status_view = RUDL::Surface.new([WIN_WIDTH, STATUS_HEIGHT])

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = PlayingGameState.new(self)

      image_loader.join
      @give_up = nil
    end # initialize

    def init_app_window
      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @app_window.set_caption('freeVikings')
      logo = RUDL::Surface.load_new GFX_DIR+'/fvlogo.tga'
      @app_window.blit(logo, [(@app_window.w/2) - (logo.w/2),\
                         (@app_window.h/3) - (logo.h/2)])
      font = TrueTypeFont.new('fonts/adlibn.ttf', 16)
      @app_window.blit(font.render('freeVikings Copyright (c) 2005 Jakub Pavlik', true, [255,255,255]), [50,250])
      @app_window.blit(font.render('freeVikings come to you as free software under GNU/GPL;', true, [255,255,255]), [50,270])
      @app_window.blit(font.render("They are provided with aim of usability,", true, [255,255,255]), [50,290])
      @app_window.blit(font.render("but with ABSOLUTELY NO WARRANTY.", true, [255,255,255]), [50,310])

      @app_window.flip
    end # init_app_window

    def init_sprites_and_images
      @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
      @baleog_face_bw = RUDL::Surface.load_new(GFX_DIR+'/erik_face_unactive.gif')
      @baleog_face = RUDL::Surface.load_new(GFX_DIR+'/erik_face.tga')
      @dead_face = RUDL::Surface.load_new(GFX_DIR+'/dead_face.png')
      @energy_punkt = RUDL::Surface.load_new(GFX_DIR+'/energypunkt.tga')
    end # init_display

    def init_vikings_team(location)
      @baleog = Viking.createWarior("Baleog", location.start)
      @erik = Viking.createSprinter("Erik", location.start)
      @olaf = Viking.createShielder("Olaf", location.start)
      @team = Team.new(@erik, @baleog, @olaf)
      # vsechny vikingy oznacime jako hrdiny:
      @team.each { |v|
        v.extend Hero
        location.add_sprite v 
      }
    end # init_vikings_team

    def finalize
      puts "Ending the game."
      exit
    end # finalize

    def repaint_status
      # vybarveni pozadi pro podobenky vikingu:
      @status_view.fill([60,60,60])
      i = 0
      @team.each { |vik|
	@status_view.blit(@face_bg, [i * 2 * VIKING_FACE_SIZE, 0])
	if vik.alive? then
	  if @team.active == vik then
	    @status_view.blit(vik.portrait.active, [i * 2 * VIKING_FACE_SIZE, 0])
	  elsif not vik.alive?
	    @status_view.blit(vik.portrait.kaput, [i * 2 * VIKING_FACE_SIZE, 0])
	  else
	    @status_view.blit(vik.portrait.unactive, [i * 2 * VIKING_FACE_SIZE, 0])
	  end
	  vik.energy.times {|j| @status_view.blit(@energy_punkt, [i*2*VIKING_FACE_SIZE + VIKING_FACE_SIZE + 2, j*@energy_punkt.h + 3])}
	end
	i += 1
      }
    end # repaint_status

    def is_exit?
      # Pokud vsichni umreli, koncime:
      unless @team.alive? then
	return true
      end
      # Pokud jsou vsichni zivi v exitu, koncime taky:
      if exited_sprites.size == @team.alive_size then
	return true
      end
      return nil
    end # is_exit?

    def give_up_game
	@give_up = true
    end

    def game_loop
      loop do
	if @team.nil? then
          location = @world.location
          init_vikings_team(location)
	elsif (@team.alive_size < @team.size) or (@give_up == true) then
	  # Nekteri hrdinove mrtvi.
	  puts '*** Some vikings died. Try once more.'
	  @world.rewind_location
	  @give_up = nil
	elsif @team.alive_size == @team.size
	  # Vsichni dosahli EXITu
	  puts '*** Oh, great! Congratulations, level completed.'
	  unless @world.next_location then
	    puts '*** Congratulations! You explored all the world!'
	    exit
	  end
	else
	  # Situace, ktera by nemela nastat
	  puts '*** Really strange situation. Nor the game loop is in it\'s first loop, nor the level completed, no vikings dead. Send a bug report, please.'
	  exit 1
	end


	frames = 0 # pomocna promenna k vypoctu fps

	# Cyklujeme, dokud se vsichni prezivsi nedostali do exitu
	# nebo to hrac nevzdal
	while (not is_exit?) and (not @give_up) do

	  # Zpracujeme udalosti:
	  if event = RUDL::EventQueue.poll then
	    @state.serve_event(event)
	  end # if je udalost

	  location.update
	  location.paint(@map_view, @team.active.center)
	  @app_window.blit(@map_view, [0,0])

	  repaint_status
	  @app_window.blit(@status_view, [0, WIN_HEIGHT - STATUS_HEIGHT])

	  if FreeVikings::OPTIONS["display_fps"] then
	    @app_window.filled_polygon [[8,8],[60,8],[60,20],[8,20]], [0,0,0]
            unless (s = Time.now.sec) == 0 
              @app_window.print([10,10], "fps: #{frames / s}", 0xFFFFFFFF)
            else
              frames = 0
            end
	  end

	  @app_window.flip
	  frames += 1
	  
	end # while not location.exited?
      end # while not self.game_over?
    end # game_loop

    private

    # Vrati pole vsech sprajtu, ktere se vyskytuji na exitu

    def exited_sprites
      l = @world.location
      on_exit = l.sprites_on_rect(l.exitter.rect)
      on_exit.delete(l.exitter)
      exited_sprites = on_exit.find_all {|sprite| @team.member? sprite}
      return exited_sprites
    end

  end
end # module
