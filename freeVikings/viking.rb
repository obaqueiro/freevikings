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
      @position = [70, 60]
      @move_validator = NullMoveValidator # objekt overujici moznost presunu na posici
    end

    def paint(surface)
      surface.blit(@image.image(@state.to_s), coordinate_in_surface(surface))
    end

    def move_left
      @state.move_left
      @velocity_horis.value = - BASE_VELOCITY
      set_move
    end

    def move_right
      @state.move_right
      @velocity_horis.value = BASE_VELOCITY
      set_move
    end

    def stop
      @state.stop
      @velocity_horis.value = @velocity_vertic.value = 0
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
      next_top = @position[1] + (@velocity_vertic.value * time_delta)
      next_left = @position[0] + (@velocity_horis.value * time_delta)
      return [next_left, next_top]
    end

    def update_position
      if @move_validator.is_position_valid?(self, next_position) then
	@position = next_position
	@last_update_time = Time.now.to_f
      else
	stop
	@velocity_horis.value = @velocity_vertic.value = 0
      end
      @viking_log.debug("#{@name}'s state: #{@state.to_s}")
    end

    private
    def set_move
      @last_update_time = Time.now.to_f
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
