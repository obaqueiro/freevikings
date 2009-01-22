# viking.rb
# igneus 20.1.2004

require 'deadviking.rb'

require 'vikingstate.rb'
require 'collisiontest.rb'
require 'inventory.rb'
require 'sophisticatedspritemixins.rb'
require 'talkable.rb'
require 'transportable.rb'
require 'ladder.rb'

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

    BASE_VELOCITY = 100 # 70

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
      # auxiliary rectangle used for various checks
      # (it must always have the same width and height as @rect!)
      @aux_rect = @rect.dup
      # another auxiliary rectangle used only in try_to_descend
      # (don't use it anywhere else!)
      @desc_rect = Rectangle.new 0,0,0,0

      @energy = MAX_ENERGY

      @portrait = nil

      @inventory = Inventory.new

      # y value of place where viking started falling; is used to compute
      # if he should be hurt when touching a hard surface
      @start_fall = nil

      @knockout_duration = TimeLock.new

      # an eventual transporter transporting the viking
      @transported_by = nil

      # says if viking is trying to climb
      @try_to_climb = false

      @location = NullLocation.instance

      # BottomPanel::VikingView will be assigned here
      # (NullView is for tests etc.)
      @view = BottomPanel::VikingView::NullView.new
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

    def view=(v)
      @view = v
      @inventory.observer = v
    end

    # Takes the Viking off one energy point.
    # If the energy falls onto zero, Viking#destroy is called.
    # Returns his energy after the injury.

    def hurt
      @energy -= 1
      destroy if @energy <= 0

      @view.update_view

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
        @view.update_view
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
      @view.update_view
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
      @location.active_objects_on_rect(@rect.expand(1,2)) { |o|
        o.activate self
      }
    end

    def s_f_func_off
      @location.active_objects_on_rect(@rect.expand(1,2)) { |o| 
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
        @try_to_climb = :up
        s_f_func_on
      end
    end

    def down
      if @state.climbing? then
        @state.vertical_state = ClimbingDownState.new(@state)
      else
        @try_to_climb = :down
        s_f_func_off
      end
    end

    # Called whenever UP or DOWN key is released.
    # Viking stops on the ladder

    def climb_stop
      @try_to_climb = false

      unless @state.climbing?
        return
      end

      @state.vertical_state = ClimbingHavingRestState.new(@state)
    end

    # Called by Ladder when it is activated by Viking

    def climb(ladder, direction)
      if ! proper_ladder_collision?(ladder) then
        return
      end

      @try_to_climb = false
      @start_fall = nil
      # Viking must stop walking before he can start climbing
      @state.stop
      # and end any ability-connected activities
      @state.ability.space_off
      @state.ability.d_off

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
        @log.error "Unknown transporter #{transporter} is trying to move #{@name}"
        return
      end

      @aux_rect.set_pos(@rect.left + delta_x.to_i,
                        transporter.rect.top-(HEIGHT+1))
      if @location.area_free?(@aux_rect) then
        @rect.copy_pos @aux_rect
      else
        transporter.end_transport_of self
      end
    end

    # Updates Viking's internal state.

    def update
      collect_items

      update_knockout

      # don't modify these variables!
      @next_left = next_left
      @next_top = next_top

      unless (move_xy or move_y_only)
        @log.warn "update: Viking #{name} cannot move in any axis. He could have stucked."
      end

      try_to_climb if @try_to_climb
      update_climbing if @state.climbing?
      try_to_fall
      fall_if_head_on_the_ceiling
      try_to_descend

      update_transport # defined in mixin Transportable

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
      return if @start_fall == nil

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
      @aux_rect.set_pos(@next_left, @next_top)
      if @location.area_free?(@aux_rect) then
	@log.debug "move_xy: Viking #{name}'s next position is all right."
        @rect.copy_pos @aux_rect
        return true
      else
        return false
      end
    end

    private
    def move_y_only
      @aux_rect.set_pos(@rect.left, @next_top)
      if @location.area_free?(@aux_rect) then
        @log.debug "move_y_only: Viking #{name} cannot move horizontally, but his vertical coordinate was updated successfully."
        @rect.copy_pos @aux_rect
        return true
      else
        @log.debug "move_y_only: Viking #{name} cannot move in any axis."
        return false
      end
    end

    # When UP or DOWN key is pressed, viking regularly tries to find a ladder
    # and climb it up/down

    def try_to_climb
      ladder = @location.active_objects_on_rect(@rect) {|ao|
        if ao.is_a?(Ladder) && proper_ladder_collision?(ao) then
          break ao
        end
      }

      if ladder.is_a? Ladder then
        if @try_to_climb == :down then
          ladder.deactivate(self)
        else
          ladder.activate(self)
        end
        @try_to_climb = false
      end
    end

    def update_climbing
      # At the top of ladder
      if @state.velocity_vertic < 0 && 
          @rect.top < (@ladder.rect.top - HEIGHT/2) then
        delta_y = @ladder.rect.top - (@rect.h + 1) - @rect.top
        if @location.area_free?(@rect.move(0,delta_y)) then
          @rect.move!(0,delta_y)
          @state.vertical_state = OnGroundState.new(@state)
        end
      end

      # At the bottom of ladder
      if @state.velocity_vertic > 0 &&
          @rect.top > (@ladder.rect.bottom - 5) then
        @ladder = nil
        fall
      end

      # Ladder might have disappeared:
      if ! @rect.collides?(@ladder.rect) then
        fall
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
        @desc_rect.set_values(@rect.left, 
                              @rect.bottom,
                              @rect.w, 
                              (@location.ticker.delta * BASE_VELOCITY).to_i)

        floor = @location.find_surface(@desc_rect)

        if floor != nil then
          @rect.top = (floor.top - @rect.h) - 1
          check_fall_injury
        end
      end
    end

    private
    def fall_if_head_on_the_ceiling
      return unless @state.rising?

      head_area = next_position
      head_area.h = 20
      unless @location.area_free?(head_area)
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
      @aux_rect.set_pos(@rect.left, 
                        @rect.top + @location.ticker.delta * BASE_VELOCITY)
      return ! @location.area_free?(@aux_rect)
    end

    private
    def collect_items
      @location.items_on_rect(rect) do |i|
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

    # Says if viking collides with the ladder so that he can climb it

    def proper_ladder_collision?(ladder)
      @rect.expand2(0,0,0,2).collides?(ladder.rect) &&
        (ladder.rect.center[0] - @rect.center[0]).abs < 20
    end
  end # class Viking
end # module

require 'warior.rb'
require 'sprinter.rb'
require 'shielder.rb'

