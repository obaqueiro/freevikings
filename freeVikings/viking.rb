# viking.rb
# igneus 20.1.2004

require 'sprite.rb'
require 'vikingstate.rb'
require 'imagebank.rb'
require 'movevalidator'
require 'log4r'

module FreeVikings

  class Viking < Sprite
    # Sprite trida pro postavicky vikingu

    attr_accessor :state
    attr_accessor :name
    attr_writer :move_validator

    def initialize()
      super
      @viking_log = Log4r::Logger.new('viking_log')
      @viking_log.level = Log4r::INFO
      @viking_log.outputters = Log4r::StderrOutputter.new('viking_stderr_out')
      init_images
      @name = 'Swen'
      @state = StandingVikingState.new(self)
      @viking_log.debug("Viking #{@name} initialised.")
      @last_position = @position = [90, 60]
      @move_validator = NullMoveValidator # objekt overujici moznost presunu na posici
    end

    def paint(surface)
      surface.blit(@image.image(@state.to_s), coordinate_in_surface(surface))
    end

    def move_left
      @state.move_left
      set_move
      start_moving_safely
    end

    def move_right
      @state.move_right
      set_move
      start_moving_safely
    end

    def stop
      @state.stop
      velocity_horiz.value = velocity_vertic.value = 0
    end

    def top
      update_position if moving?
      return @position[1]
    end

    def left
      update_position if moving?
      return @position[0]
    end

    # vrati souradnice stredu aktualniho obrazku

    def center
      [left + (@image.image.w / 2), top + (@image.image.w / 2)]
    end

    def moving?
      @state.moving?
    end

    def next_position
      time_now = Time.now.to_f
      time_delta = time_now - @last_update_time
      # Zde se musi posice zjistovat primo z instancni promenne, protoze
      # pristupove metody left a top ji aktualisuji
      next_top = @position[1] + (velocity_vertic.value * time_delta)
      next_left = @position[0] + (velocity_horiz.value * time_delta)
      return [next_left, next_top]
    end

    def update_position
      if @move_validator.is_position_valid?(self, next_position) then
	@last_position, @position = @position, next_position
	update_time
      else
	stop
	velocity_horiz.value = velocity_vertic.value = 0
      end
      @viking_log.debug("#{@name}'s state: #{@state.to_s}")
    end

    private
    def velocity_vertic
      @state.velocity_vertic
    end

    private
    def velocity_horiz
      @state.velocity_horiz
    end

    private
    # zkontroluje, jestli muze vykrocit a pokud ne, nevykroci.
    def start_moving_safely
      unless @move_validator.is_position_valid?(self, next_position)
	unmove
      end
    end

    private
    # vrati vikinga na posledni posici
    def unmove
      stop
      @position = @last_position
    end

    private
    # Aktualisuje cas posledni aktualisace posice
    def update_time
      @last_update_time = Time.now.to_f
    end

    private
    def set_move
      update_time
    end

    private
    def init_images
      @image = ImageBank.new(self)
      @image.add_pair('standing', Image.new('baleog_standing.png'))
      @image.add_pair('moving_left', Image.new('baleog_left.png'))
      @image.add_pair('moving_right', Image.new('baleog_right.png'))
    end
  end # class Viking
end # module
