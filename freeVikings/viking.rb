# viking.rb
# igneus 20.1.2004

require 'sprite.rb'
require 'vikingstate.rb'
require 'imagebank.rb'
require 'movevalidator.rb'
require 'log4r'

module FreeVikings

  class Viking < Sprite
    # Sprite trida pro postavicky vikingu

    BASE_VELOCITY = 100

    attr_accessor :state
    attr_accessor :name
    attr_writer :move_validator
    attr_reader :energy

    def initialize(name = "")
      super()
      @viking_log = Log4r::Logger.new('viking_log')
      @viking_log.level = Log4r::ERROR
      @viking_log.outputters = Log4r::StderrOutputter.new('viking_stderr_out')
      @name = name
      @state = StandingVikingState.new(self)
      @viking_log.debug("Viking #{@name} initialised.")
      @last_position = @position = [121, 20]
      @last_update_time = Time.now.to_f
      @move_validator = NullMoveValidator # objekt overujici moznost presunu na posici
      @energy = 3 # zivotni sila
    end

    def Viking.createWarior(name="")
      return Warior.new(name)
    end

    def Viking.createSprinter(name="")
      return Sprinter.new(name)
    end

    def Viking.createShielder(name="")
      return Shielder.new(name)
    end

    def paint(surface)
      surface.blit(@image.image(@state.to_s), coordinate_in_surface(surface))
    end

    def hurt
      @energy -= 1
      destroy if @energy <= 0
    end

    def alive?
      @state.alive?
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
    end

    def destroy
      @state.destroy
    end

    def top
      return @position[1]
    end

    def left
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
      update_state
      time_now = Time.now.to_f
      time_delta = time_now - @last_update_time
      # Zde se musi posice zjistovat primo z instancni promenne, protoze
      # pristupove metody left a top ji aktualisuji
      next_top = @position[1] + (velocity_vertic.value * time_delta)
      next_left = @position[0] + (velocity_horiz.value * time_delta)
      return [next_left, next_top]
    end

    # Aktualisuje posici vikinga.

    def update
      if @move_validator.is_position_valid?(self, next_position) then
	@last_position, @position = @position, next_position
	update_time
      else
	@state.stuck
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
      @position = @last_position
    end

    private
    # Aktualisuje cas posledni aktualisace posice
    def update_time
      @last_update_time = Time.now.to_f
    end

    private
    def update_state
      # je volno pod vikingem? Jestli ano, zacne padat.
      if @move_validator.is_vertical_position_valid?(self, [@position[0], @position[1] + 5])
	@state = FallingVikingState.new(self, @state.dup)
      end
    end

    private
    def set_move
      update_time
    end

  end # class Viking
end # module

require 'warior.rb'
require 'sprinter.rb'
require 'shielder.rb'
