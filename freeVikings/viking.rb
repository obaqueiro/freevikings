# viking.rb
# igneus 20.1.2004

require 'sprite.rb'
require 'deadviking.rb'

require 'vikingstate.rb'
require 'imagebank.rb'
require 'nullocation.rb'
require 'log4r'

module FreeVikings

  class Viking < Sprite
    # Sprite trida pro postavicky vikingu

    BASE_VELOCITY = 65

    def initialize(name, start_position=[0,0])
      super()
      @log = Log4r::Logger['viking log']
      @name = name
      @state = Future::VikingState.new
      @log.debug("Viking #{@name} initialised.")
      @position = start_position
      @last_update_time = Time.now.to_f
      @location = NullLocation.new # objekt overujici moznost presunu na posici
      @energy = 3 # zivotni sila

      @portrait = Portrait.new('viking_face.tga', 'viking_face_unactive.tga', 'dead_face.png')

      @alive = true
    end

    def Viking.createWarior(name, start_position)
      return Warior.new(name, start_position)
    end

    def Viking.createSprinter(name, start_position)
      return Sprinter.new(name, start_position)
    end

    def Viking.createShielder(name, start_position)
      return Shielder.new(name, start_position)
    end

    attr_accessor :state
    attr_accessor :name
    attr_reader :energy
    attr_reader :portrait

    def paint(surface)
      surface.blit(@image.image(@state.to_s), coordinate_in_surface(surface))
    end

    def hurt
      @energy -= 1
      destroy if @energy <= 0
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
      @alive = nil
      @location.add_sprite DeadViking.new([left, top])
      @location.delete_sprite self
    end

    def alive?
      @alive
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

    def falling?
      @state.falling?
    end

    def next_position
      time_now = Time.now.to_f
      time_delta = time_now - @last_update_time
      # Zde se musi posice zjistovat primo z instancni promenne, protoze
      # pristupove metody left a top ji aktualisuji
      next_top = @position[1] + (velocity_vertic * time_delta)
      next_left = @position[0] + (velocity_horiz * time_delta)
      return [next_left, next_top]
    end

    # Aktualisuje posici vikinga.

    def update
      # Nyni muzeme aktualisovat posici:
      if @location.is_position_valid?(self, next_position) then
	@log.debug "update: Viking #{name}'s next position is all right."
	@position = next_position
	update_time
      else
	@log.debug "update: Viking #{name}'s next position isn't valid, he'll stuck now."
	@state.stop
      end
      # Zkusme, jestli by viking nemohl zacit padat.
      # Pokud muze zacit padat, zacne padat:
      if not @state.falling? and not on_ground?
	@state.fall
	@log.debug "update: #{@name} starts falling because there's a free space under him."
      end

      @log.debug("update: #{@name}'s state: #{@state.to_s} #{@state.dump}")
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

    private
    # Zjisti, jestli viking stoji na zemi (na pevne dlazdici)
    def on_ground?
      lowerpos = next_position
      lowerpos[1] += 2
      return nil if @location.is_position_valid?(self, lowerpos)
      return true
    end

  end # class Viking
end # module

require 'warior.rb'
require 'sprinter.rb'
require 'shielder.rb'
