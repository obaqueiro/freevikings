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

    BASE_VELOCITY = 40

    # Jeden logovaci kanal pro vsechny instance - staci to a spori se cas
    # procesoru i pamet
    @@viking_log = Log4r::Logger.new('viking_log')
    @@viking_log.level = Log4r::OFF
    @@viking_log.outputters = Log4r::StderrOutputter.new('viking_stderr_out')

    def initialize(name = "")
      super()
      @name = name
      @state = StandingVikingState.new(self, VikingState.new(self, nil))
      @@viking_log.debug("Viking #{@name} initialised.")
      @last_position = @position = [121, 20]
      @last_update_time = Time.now.to_f
      @move_validator = NullMoveValidator # objekt overujici moznost presunu na posici
      @energy = 3 # zivotni sila

      @portrait = Portrait.new('viking_face.tga', 'viking_face_unactive.tga', 'dead_face.png')
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

    attr_accessor :state
    attr_accessor :name
    attr_writer :move_validator
    attr_reader :energy
    attr_reader :portrait

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
    end

    def move_right
      @state.move_right
      set_move
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

    def space_func
    end

    def d_func
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

    # Aktualisuje posici vikinga.

    def update
      # Nyni muzeme aktualisovat posici:
      if @move_validator.is_position_valid?(self, next_position) then
	@@viking_log.debug "update: Viking #{name}'s next position is all right."
	@last_position, @position = @position, next_position
	update_time
      else
	@@viking_log.debug "update: Viking #{name}'s next position isn't valid, he'll stuck now."
	@state.stuck
      end
      # Zkusme, jestli by viking nemohl zacit padat.
      # Pokud muze zacit padat, zacne padat:
      lowerpos = next_position
      lowerpos[1] += 2
      if not @state.is_a? FallingVikingState and @move_validator.is_position_valid?(self, lowerpos)
	@state = FallingVikingState.new(self, @state)
	@@viking_log.debug "update: #{@name} starts falling because there's a free space under him."
      end

      @@viking_log.info("update: #{@name}'s state: #{@state.to_s} #{@state.dump}")
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
    # Aktualisuje cas posledni aktualisace posice
    def update_time
      @last_update_time = Time.now.to_f
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
