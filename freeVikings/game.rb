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

      @world = World.new

      # Surfaces, ktere se pouzivaji k sestaveni zobrazeni nahledu hraci plochy
      # a stavoveho radku s podobiznami vikingu
      @map_view = RUDL::Surface.new([WIN_WIDTH, WIN_HEIGHT - STATUS_HEIGHT])
      @status_view = RUDL::Surface.new([WIN_WIDTH, STATUS_HEIGHT])

      # Stav hry. Muze se kdykoli samovolne vymenit za instanci jine
      # tridy, pokud usoudi, ze by se stav mel zmenit.
      @state = PlayingGameState.new(self)

      image_loader.join
    end # initialize

    def init_app_window
      @app_window = RUDL::DisplaySurface.new([WIN_WIDTH, WIN_HEIGHT])
      @app_window.set_caption('freeVikings')
      logo = RUDL::Surface.load_new GFX_DIR+'/fvlogo.tga'
      @app_window.blit(logo, [@app_window.w/2-logo.w/2,@app_window.h/2-logo.h/2])
      @app_window.flip
    end # init_app_window

    def init_sprites_and_images
      @face_bg = RUDL::Surface.load_new(GFX_DIR+'/face_bg.tga')
      @baleog_face_bw = RUDL::Surface.load_new(GFX_DIR+'/erik_face_unactive.gif')
      @baleog_face = RUDL::Surface.load_new(GFX_DIR+'/erik_face.tga')
      @dead_face = RUDL::Surface.load_new(GFX_DIR+'/dead_face.png')
      @energy_punkt = RUDL::Surface.load_new(GFX_DIR+'/energypunkt.tga')
    end # init_display

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
      if exited_vikings.size == @team.alive_size then
	return true
      end
      return nil
    end # is_exit?

    def game_over?
      nil
    end # game_over?

    def game_loop
      while not self.game_over? do

	if @team.nil? then
	  # Prvni iterace. Bude se inicialisovat. Tady nemusime nic.
	elsif @team.alive_size < @team.size then
	  # Nekteri hrdinove mrtvi.
	  puts '*** Some vikings died. Try once more.'
	  @world.rewind_location
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

	location = @world.location

	@baleog = Viking.createWarior("Baleog", location.start)
	@erik = Viking.createSprinter("Erik", location.start)
	@olaf = Viking.createShielder("Olaf", location.start)

	@team = Team.new(@erik, @baleog, @olaf)
	@team.each { |v|
	  v.extend Hero # vsechny vikingy oznacime jako hrdiny
	  location.add_sprite v }

	frames = 0 # pomocna promenna k vypoctu fps

	# Cyklujeme, dokud se vsichni prezivsi nedostali do exitu
	# nebo to hrac nevzdal
	while not is_exit? do

	  # Zpracujeme udalosti:
	  if event = RUDL::EventQueue.poll then
	    @state.serve_event(event)
	  end # if je udalost

	  location.update
	  location.paint(@map_view, @team.active.center)
	  @app_window.blit(@map_view, [0,0])

	  repaint_status
	  @app_window.blit(@status_view, [0, WIN_HEIGHT - STATUS_HEIGHT])

	  @app_window.flip
	  frames += 1
	  
	end # while not location.exited?
      end # while not self.game_over?
    end # game_loop

    private

    def exited_vikings
      l = @world.location
      on_exit = l.sprites_on_rect(l.exitter.rect)
      on_exit.delete(l.exitter)
      exited_vikings = on_exit.find_all {|sprite| @team.member? sprite}
      return exited_vikings
    end

  end
end # module
