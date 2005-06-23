# viking.rb
# igneus 20.1.2004

require 'log4r'

require 'sprite.rb'
require 'deadviking.rb'

require 'vikingstate.rb'
require 'imagebank.rb'
require 'nullocation.rb'
require 'collisiontest.rb'
require 'inventory.rb'

=begin
= Viking
=end

module FreeVikings

  class Viking < Sprite

    BASE_VELOCITY = 65
    WIDTH = 80
    HEIGHT = 100
    MAX_ENERGY = 3

    def initialize(name, start_position=[0,0])
      super()
      @log = Log4r::Logger['viking log']
      @name = name
      @state = VikingState.new
      @log.debug("Viking #{@name} initialised.")
      @rect = Rectangle.new start_position[0], start_position[1], WIDTH, HEIGHT
      @last_update_time = Time.now.to_f
      @energy = MAX_ENERGY # zivotni sila

      @portrait = Portrait.new('viking_face.tga', 'viking_face_unactive.tga', 'dead_face.png')

      @inventory = Inventory.new
    end

    attr_reader :inventory

    def Viking.createWarior(name, start_position)
      return Warior.new(name, start_position)
    end

    def Viking.createSprinter(name, start_position)
      return Sprinter.new(name, start_position)
    end

    def Viking.createShielder(name, start_position)
      return Shielder.new(name, start_position)
    end

    attr_reader :name
    attr_reader :state
    attr_reader :energy
    attr_reader :portrait

    def paint(surface)
      surface.blit(@image.image(@state.to_s), coordinate_in_surface(surface))
    end

    def hurt
      @energy -= 1
      destroy if @energy <= 0
    end

    def heal
      if @energy < MAX_ENERGY
        @energy += 1
        return true
      else
        return false
      end
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
      @energy = 0
      @location.add_sprite DeadViking.new([left, top])
      @location.delete_sprite self
    end

    def alive?
      @energy > 0
    end

    def top
      @rect.top
    end

    def left
      @rect.left
    end

    def space_func_on
    end

    def space_func_off
    end

    def d_func_on
    end

    def d_func_off
    end

    def use_item
      if @inventory.active.apply(self) then
        @inventory.erase_active
      end
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

    def standing?
      @state.standing?
    end

    def next_position
      time_now = Time.now.to_f
      time_delta = time_now - @last_update_time
      # Zde se musi posice zjistovat primo z instancni promenne, protoze
      # pristupove metody left a top ji aktualisuji
      next_top = @rect.top + (velocity_vertic * time_delta)
      next_left = @rect.left + (velocity_horiz * time_delta)
      Rectangle.new next_left, next_top, WIDTH, HEIGHT
    end

    # Aktualisuje posici vikinga.

    def update
      collect_items # sebere vsechno, na co narazi :o)

      @rect.h = image.h
      @rect.w = image.w

      # Nyni muzeme aktualisovat posici:
      if @location.is_position_valid?(self, next_position) then
	@log.debug "update: Viking #{name}'s next position is all right."
	@rect = next_position
	update_time
      else
	@log.debug "update: Viking #{name}'s next position isn't valid, he'll stuck now."
	@state.stop
        @state.descend
      end
      if @state.falling? and on_ground? then
        @state.descend
      end
      # Zkusme, jestli by viking nemohl zacit padat.
      # Pokud muze zacit padat, zacne padat:
      if not @state.rising? and not @state.falling? and not on_ground?
	@state.fall
	@log.debug "update: #{@name} starts falling because there's a free space under him."
      end

      @log.debug("update: #{@name}'s state: #{@state.to_s} #{@state.dump}")
    end

    private
    def velocity_vertic
      @state.velocity_vertic * BASE_VELOCITY
    end

    private
    def velocity_horiz
      @state.velocity_horiz * BASE_VELOCITY
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
      # stoji viking na stite?
      return true if on_shield?
      # je pod vikingem volne misto?
      lowerpos = next_position
      lowerpos.top += 2
      return nil if @location.is_position_valid?(self, lowerpos)
      # viking stoji na pevne zemi:
      return true
    end

    private
    def on_shield?
      shield = @location.sprites_on_rect(rect).find {|s| s.is_a? Platform}
      if shield and CollisionTest.bottom_collision?(rect, shield.rect) then
        return true
      else
        return false
      end
    end

    private
    def collect_items
      @location.items_on_rect(rect).each do |i|
        @location.delete_item i
        @inventory.put i
      end
    end

  end # class Viking
end # module

require 'warior.rb'
require 'sprinter.rb'
require 'shielder.rb'
