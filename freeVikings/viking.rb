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
require 'map.rb' # kvuli const. TILE_SIZE
require 'leggedspritemixins.rb'

=begin
= Viking
=end

module FreeVikings

  class Viking < Sprite

    include LeggedSpriteMixins::Walking

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
      @energy = MAX_ENERGY # zivotni sila

      @portrait = nil

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

    # Aktualisuje posici vikinga.

    def update
      collect_items # sebere vsechno, na co narazi :o)

      unless (move_xy or move_y_only) then
        @log.warn "update: Viking #{name} cannot move in any axis. He could have stucked."
      end

      try_to_descend
      try_to_fall
      update_rect_w_h

      @log.debug("update: #{@name}'s state: #{@state.to_s} #{@state.dump}")
    end

    private
    def move_xy
      next_pos = Rectangle.new(next_left, next_top, @rect.w, @rect.h)
      if @location.is_position_valid?(self, next_pos) then
	@log.debug "update: Viking #{name}'s next position is all right."
        @rect = next_pos
        return true
      else
        return false
      end
    end

    private
    def move_y_only
      next_pos = Rectangle.new(@rect.left, next_top, @rect.w, @rect.h)
      if @location.is_position_valid?(self, next_pos) then
        @log.debug "update: Viking #{name} cannot move horizontally, but his vertical coordinate was updated successfully."
        @rect = next_pos
        return true
      else
        @log.debug "update: Viking #{name} cannot move in any axis."
        return false
      end
    end

    private
    def try_to_fall
      # Zkusme, jestli by viking nemohl zacit padat.
      # Pokud muze zacit padat, zacne padat:
      if not @state.rising? and not @state.falling? and not on_some_surface?
	@state.fall
	@log.debug "update: #{@name} starts falling because there's a free space under him."
      end
    end

    private
    def try_to_descend
      if @state.falling? and on_some_surface? then
        @state.descend
        descend if on_ground?
      end
    end

    private
    def update_rect_w_h
      @rect.h = image.h
      @rect.w = image.w
    end

    private
    def next_left
      next_left = @rect.left + (velocity_horiz * @location.ticker.delta)
    end

    private
    def next_top
      next_top = @rect.top + (velocity_vertic * @location.ticker.delta)
    end

    private
    def next_position
      Rectangle.new next_left, next_top, @rect.w, @rect.h
    end

    private
    def velocity_horiz
      @state.velocity_horiz * BASE_VELOCITY
    end

    private
    def velocity_vertic
      @state.velocity_vertic * BASE_VELOCITY
    end

    private
    # Zjisti, jestli viking stoji na zemi (na pevne dlazdici)
    def on_ground?
      # stoji viking na stite?
      # return true if on_shield?
      # je pod vikingem volne misto?
      lowerpos = Rectangle.new(@rect.left, 
                               @rect.top + @location.ticker.delta * BASE_VELOCITY, 
                               @rect.w, 
                               @rect.h)
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
    def on_some_surface?
      on_ground? or on_shield?
    end

    private
    def collect_items
      @location.items_on_rect(rect).each do |i|
        @location.delete_item i
        @inventory.put i
      end
    end

    private
    def descend
      @rect.top += Map::TILE_SIZE - (@rect.bottom % Map::TILE_SIZE)
    end

  end # class Viking
end # module

require 'warior.rb'
require 'sprinter.rb'
require 'shielder.rb'
