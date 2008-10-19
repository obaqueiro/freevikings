# viking.rb
# igneus 20.1.2004

require 'deadviking.rb'

require 'vikingstate.rb'
require 'collisiontest.rb'
require 'inventory.rb'
require 'sophisticatedspritemixins.rb'
require 'talkable.rb'
require 'transportable.rb'

module FreeVikings

  class Viking < Sprite

    include SophisticatedSpriteMixins::Walking
    include Talkable
    include Transportable

    # As Olaf is initialized he gives a reference to his shield
    # here so the vikings can check collision with a shield quickly without
    # searching for it every update.
    @@shield = nil

    protected

    def Viking.shield
      @@shield
    end

    def Viking.shield=(s)
      @@shield = s
    end

    public

    # Viking's default velocity in pixels per second.

    BASE_VELOCITY = 70

    # Sizes of the vikings' graphics.

    WIDTH = 80
    HEIGHT = 100

    # Initial number of energy points. The viking should never have more then 
    # on the beginninig.

    MAX_ENERGY = 3

    # Time in seconds for which the viking is unusable after he is knocked
    # out (e.g. when he falls from a high place).

    KNOCK_OUT_DURATION = 4

    # Creates a new viking. Parameter name is a String,
    # start_position should be an Array or a Rectangle.

    def initialize(name, start_position=[0,0])
      super()
      @log = Log4r::Logger['viking log']
      @name = name
      @state = VikingState.new
      @log.debug("Viking #{@name} initialised.")
      @rect = Rectangle.new start_position[0], start_position[1], WIDTH, HEIGHT
      @energy = MAX_ENERGY

      @portrait = nil

      @inventory = Inventory.new

      @start_fall = -1
      @knockout_duration = TimeLock.new

      @transported_by = nil # an eventual transporter transporting the viking

      @location = NullLocation.instance
    end

    # Factory methods which create subclasses' instances.

    def Viking.createWarior(name, start_position)
      return Warior.new(name, start_position)
    end

    def Viking.createSprinter(name, start_position)
      return Sprinter.new(name, start_position)
    end

    def Viking.createShielder(name, start_position)
      return Shielder.new(name, start_position)
    end

    # Returns Viking's name.

    attr_reader :name

    # Returns Viking's state. To learn more about it, study documentation 
    # for class VikingState.

    attr_reader :state

    # Returns Viking's energy as a number which shouldn't ever overgrow
    # Viking::MAX_ENERGY and descend under zero.

    attr_reader :energy

    # Returns a Portrait of the Viking.

    attr_reader :portrait

    # Viking's Inventory.

    attr_reader :inventory

    # Takes the Viking off one energy point.
    # If the energy falls onto zero, Viking#destroy is called.
    # Returns his energy after the injury.

    def hurt
      @energy -= 1
      destroy if @energy <= 0
      return @energy
    end

    # Hurts the viking and knocks him out for Viking::KNOCK_OUT_DURATION 
    # seconds.

    def hurt_and_knockout
      @state.knockout
      @knockout_duration = TimeLock.new KNOCK_OUT_DURATION, @location.ticker
      hurt
    end

    # If the Viking doesn't have full energy (see Viking::MAX_ENERGY), 
    # adds him one energy point and returns true.
    # Otherwise false is returned and nothing added.

    def heal
      if @energy < MAX_ENERGY
        @energy += 1
        return true
      else
        return false
      end
    end

    # Sets energy to zero, deletes the Viking from the Location and
    # adds a new Sprite representing a corpse into it.
    # This method is called when the Viking is killed directly 
    # without any discussion (e.g. when a skyscraper falls onto his uncovered 
    # head) 
    # or when his energy falls onto zero (see Viking#hurt).
    # Returns the Viking itself.

    def destroy
      @energy = 0
      @inventory.clear
      @location.add_sprite DeadViking.new([left, top])
      @location.delete_sprite self
      self
    end

    # Switch on/off Viking's first special ability.

    def space_func_on
    end

    def space_func_off
    end

    # Switch on/off Viking's second special ability.

    def d_func_on
    end

    def d_func_off
    end

    # Switch on/off ActiveObjects which viking can reach (in Lost Vikings 1
    # the same keys which switch active objects do also change viking's state
    # if he is "bubbled" or mounted as an operator on some machine)

    def s_f_func_on
      @location.active_objects_on_rect(@rect.expand(1,1)).each { |o|
        o.activate 
      }
    end

    def s_f_func_off
      @location.active_objects_on_rect(@rect.expand(1,1)).each { |o| 
        o.deactivate 
      }
    end

    # Tries to use the active Item from the Viking's Inventory.
    # If it is successfull, the used Item is ejected and true returned, 
    # false otherwise.

    def use_item
      if @inventory.active.apply(self) then
        @inventory.erase_active
        return true
      end
      return false
    end

    # Called by objects which transport vikings (lifts, ...)
    # to update viking's position

    def transport_move(delta_x, delta_y, transporter)
      unless transporter == @transported_by
        @log.warn "Unknown transporter #{transporter} is trying to move #{@name}"
        return
      end

      new_rect = Rectangle.new(@rect.left + delta_x, @rect.top + delta_y,
                               @rect.w, @rect.h)
      if @location.area_free?(new_rect) then
        @rect = new_rect
      end
    end

    # Updates Viking's internal state.

    def update
      collect_items

      update_knockout

      unless (move_xy or move_y_only)
        @log.warn "update: Viking #{name} cannot move in any axis. He could have stucked."
      end

      try_to_fall
      fall_if_head_on_the_ceiling
      try_to_descend

      update_rect_w_h

      @log.debug("update: #{@name}'s state: #{@state.to_s} #{@state.dump}")

      nil
    end

    # This method causes the Viking to fall. For this purpose you could also 
    # use
    #
    # aViking.state.fall
    #
    # where aViking is Viking instance, but don't do this, because
    # Viking#fall does important work for the mechanism of fall injury
    # detection.

    def fall
      @start_fall = @rect.top
      @state.fall
    end

    private
    def descend_onto_ground
      tile_size = @location.map.tile_height

      if on_ground? and not (@rect.bottom % tile_size == 0) then
          @rect.top += tile_size - (@rect.bottom % tile_size)
      end
      @rect.top -= 1
    end

    private
    def descend_onto_static_object
      while @location.area_free?(@rect) do
        @rect.top += 1
      end
      @rect.top -= 1
    end

    # Looks if the viking hasn't fallen too deep.
    # If so, he is hurt.
    private
    def check_fall_injury
      @fall_height = @rect.top - @start_fall
      fall_velocity = velocity_vertic
      @state.descend
      if (@fall_height >= 3 * HEIGHT and fall_velocity >= BASE_VELOCITY) then
        @log.debug "descend: #{@name} has felt from a big height (#{@fall_height}) and is hurt."
        hurt_and_knockout
      end
    end

    private
    def move_xy
      next_pos = Rectangle.new(next_left, next_top, @rect.w, @rect.h)
      if @location.area_free?(next_pos) then
	@log.debug "move_xy: Viking #{name}'s next position is all right."
        @rect = next_pos
        return true
      else
        return false
      end
    end

    private
    def move_y_only
      next_pos = Rectangle.new(@rect.left, next_top, @rect.w, @rect.h)
      if @location.area_free?(next_pos) then
        @log.debug "move_y_only: Viking #{name} cannot move horizontally, but his vertical coordinate was updated successfully."
        @rect = next_pos
        return true
      else
        @log.debug "move_y_only: Viking #{name} cannot move in any axis."
        return false
      end
    end

    private
    def try_to_fall
      if not @state.rising? and not @state.falling? and not on_some_surface?
	fall
	@log.debug "try_to_fall: #{@name} starts falling because there's a free space under him."
      end
    end

    private
    def try_to_descend
      if @state.falling? and on_some_surface? then
        @log.debug "try_to_descend: #{@name} descended onto some solid surface."
        lowerpos = Rectangle.new(@rect.left, 
                                 @rect.top + @location.ticker.delta * BASE_VELOCITY, 
                                 @rect.w, 
                                 @rect.h)

        if @location.static_objects.area_free? lowerpos
          descend_onto_ground
        else
          descend_onto_static_object
        end

        check_fall_injury
      end
    end

    private
    def fall_if_head_on_the_ceiling
      head_area = next_position
      head_area.h = 20
      if @state.rising? and not @location.area_free?(head_area) then
        @log.debug "fall_if_head_on_the_ceiling: #{@name} stroke ceiling with his head and starts falling."
        fall
      end
    end

    private
    def update_rect_w_h
      @rect.h = image.h
      @rect.w = image.w
    end

    private
    def update_knockout
      if @state.knocked_out? and @knockout_duration.free? then
        @state.unknockout
      end
    end

    private
    # Says if the viking is standing on a solid ground (tile or static object)
    def on_ground?
      lowerpos = Rectangle.new(@rect.left, 
                               @rect.top + @location.ticker.delta * BASE_VELOCITY, 
                               @rect.w, 
                               @rect.h)
      return ! @location.area_free?(lowerpos)
    end

    private
    def on_shield?
      if Viking.shield and 
          Viking.shield.rect.collides?(@rect) and
          CollisionTest.bottom_collision?(@rect, Viking.shield.rect) then
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
        begin
          @inventory.put i
          @location.delete_item i
        rescue Inventory::NoSlotFreeException
          # We don't have to do anything here. If @inventory is
          # full, an exception is raised in Inventory#put.
          # Then '@location.delete_item i' isn'texecuted and nothing
          # is changed.
        end
      end
    end

  end # class Viking
end # module

require 'warior.rb'
require 'sprinter.rb'
require 'shielder.rb'

