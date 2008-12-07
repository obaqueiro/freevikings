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

    DEFAULT_Z_VALUE = 100

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

    # Sizes of the vikings' graphics. (Not of their collision area, which is
    # a bit smaller!)

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
      @log.debug("Initialising Viking '#{@name}'")

      @name = name
      @state = VikingState.new

      # @paint_rect is wider than @collision_rect
      @rect = @collision_rect = Rectangle.new(start_position[0], start_position[1], WIDTH-10, HEIGHT-1)
      @paint_rect = RelativeRectangle.new(@rect, -5, 0, 10, 1)

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

    # RelativeRectangle dependent on Viking#rect; a bit smaller.

    attr_reader :paint_rect

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
        o.activate self
      }
    end

    def s_f_func_off
      @location.active_objects_on_rect(@rect.expand(1,1)).each { |o| 
        o.deactivate self
      }
    end

    def move_left
      if @state.climbing? then
        fall        
      end

      @state.move_left
    end

    def move_right
      if @state.climbing? then
        fall
      end

      @state.move_right
    end

    # Normally falls back to s_f_func_on or s_f_func_off,
    # but on ladder makes the viking move.

    def up
      if @state.climbing? then
        @state.vertical_state = ClimbingUpState.new(@state)
      else
        s_f_func_on
      end
    end

    def down
      if @state.climbing? then
        @state.vertical_state = ClimbingDownState.new(@state)
      else
        s_f_func_off
      end
    end

    # Viking stops on the ladder

    def climb_stop
      unless @state.climbing?
        return
      end

      @state.vertical_state = ClimbingHavingRestState.new(@state)
    end

    # Called by Ladder when it is activated by Viking

    def climb(ladder, direction)
      if (ladder.rect.center[0] - @rect.center[0]).abs > 20 then
        return
      end

      @rect.left = ladder.collision_rect.center[0] - @rect.w/2
      @state.vertical_state = case direction
                              when :up
                                ClimbingUpState.new(@state)
                              when :down
                                ClimbingDownState.new(@state)
                              else
                                raise ArgumentError, "Bad direction '#{direction}'"
                              end
      @ladder = ladder
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

      new_rect = Rectangle.new(@rect.left + delta_x.to_i, @rect.top + delta_y.to_i,
                               @rect.w, @rect.h)
      if @location.area_free?(new_rect) then
        @rect.copy_values new_rect
      end
    end

    # Updates Viking's internal state.

    def update
      collect_items

      update_knockout

      unless (move_xy or move_y_only)
        @log.warn "update: Viking #{name} cannot move in any axis. He could have stucked."
      end

      update_climbing
      try_to_fall
      fall_if_head_on_the_ceiling
      try_to_descend

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
        @rect.copy_values next_pos
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
        @rect.copy_values next_pos
        return true
      else
        @log.debug "move_y_only: Viking #{name} cannot move in any axis."
        return false
      end
    end

    def update_climbing
      if @state.climbing? then
        if @state.velocity_vertic < 0 && 
            @rect.top < (@ladder.rect.top - 30) then
          @rect.top = @ladder.rect.top - (@rect.h + 1)
          @state.vertical_state = OnGroundState.new(@state)
        end
      end
    end

    private
    def try_to_fall
      if @state.climbing? or @state.rising? or @state.falling? or on_ground?
        return
      end

      fall
      @log.debug "try_to_fall: #{@name} starts falling because there's a free space under him."
    end

    private
    def try_to_descend
      if @state.falling?
        # Rectangle 'lowerpos' is Rectangle of viking's width, height equal
        # to change of position, placed under his feet
        lowerpos = Rectangle.new(@rect.left, 
                                 @rect.bottom,
                                 @rect.w, 
                                 (@location.ticker.delta * BASE_VELOCITY).to_i)

        floor = @location.find_surface(lowerpos)

        if floor != nil then
          @rect.top = (floor.top - @rect.h) - 1
          check_fall_injury
        end
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

