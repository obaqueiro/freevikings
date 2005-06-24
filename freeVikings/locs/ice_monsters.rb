# ice_monsters.rb
# igneus 27.6.2005

# Monsters script for location Ice Land

require 'switch'
require 'imagebank'
require 'group'
require 'sprite'
require 'monster'
require 'apple'
require 'killtoy'
require 'monsters/bear'

# === CONSTANTS:

module IceLand

  include FreeVikings

  module FirstCorridor
    BAY_SWITCHGROUP_Y = 230
    BAYS_X = [640, 840, 1040]
  end # module FirstCorridor
  
  SWITCH_GFX = {'true' => Image.new('ice_map/ice_switch_on.tga'),
                'false' => Image.new('ice_map/ice_switch_off.tga')}

  # WalkingBear.
  # The Bear which walks around his initial position.
  class WalkingBear < FreeVikings::Bear

    VELOCITY = 50

    RIGHT = 1
    LEFT = -1

    def initialize(position, max_walk_length=100)
      super(position)
      @max_walk_length = max_walk_length
      @teritory_center = @rect.left + @rect.w / 2
      @walk_length = 0
      rand <= 0.5 ? move_left : move_right
      new_walk_length
    end

    def update
      @rect.left += velocity_horiz * @location.ticker.delta
      turn if on_turn_point?
      bash_heroes
    end

    private

    def new_walk_length
      @walk_length = rand * @max_walk_length
      @dest = @teritory_center + (@state.velocity_horiz * @walk_length)
    end

    def turn
      move_left if @rect.left >= @teritory_center
      move_right if @rect.left <= @teritory_center

      n = new_walk_length
      # puts @state.direction, " ", n
    end

    def on_turn_point?
      if @state.velocity_horiz < 0 and 
          @rect.left <= @dest then
        return true
      end
      if @state.velocity_horiz > 0 and 
          @rect.left >= @dest then
        return true
      end

      return false
    end

    def velocity_horiz
      @state.velocity_horiz * BASE_VELOCITY
    end
  end # class WalkingBear

  class IceSwitch < FreeVikings::Switch
    def initialize(position, initial_state)
      super(position, initial_state, nil, IceLand::SWITCH_GFX)
    end
  end # class IceSwitch

  # A SwitchGroup is a Group of Switches.
  # It's members have all the same update Proc which updates the state of
  # the Group.
  # A SwitchGroup has it's combination of the member switches' states which 
  # means 'open'. All the other combinations mean 'closed'.
  # This combination is given as an argument to the constructor, it should
  # be in form of an Array of true and false values.
  class SwitchGroup < FreeVikings::Group

    def initialize(combination, update_proc, *members)
      super()
      @memberproc = Proc.new { self.update_combination }
      members.each {|m| add m}
      @combination = combination
      @proc = update_proc
      open = false
      update_combination
    end

    def add(member)
      member.action = @memberproc
      @members.push member
    end

    def update_combination
      0.upto(@combination.size) do |i|
        if @members[i] and @combination[i] == @members[i].state then
          next
        else
          open = false
          return
        end
      end
      open = true
    end

    def open?
      @open
    end

    def closed?
      ! @open
    end

    private
    def open=(state)
      @open = state
      @proc.call @open
    end
  end # class SwitchGroup
end # module IceLand


include FreeVikings
include IceLand


# === ITEMS:

LOCATION.add_item Apple.new([360 + 5,170])
LOCATION.add_item Killtoy.new([985, 330])

# === ACTIVE OBJECTS:

# The first switch in the first corridor. Erik can reach it only with 
# Olaf's help. It does nothing.
switch = Switch.new([360 + 5, 80], false, Proc.new {}, IceLand::SWITCH_GFX)
LOCATION.add_active_object switch

# The group of three switches over the first corridor. Erik can reach every 
# of them.
switchgroup = SwitchGroup.new(
                              [true, false, false],
                              Proc.new {|state| nil},
                              IceSwitch.new([IceLand::FirstCorridor::BAYS_X[0] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], false),
                              IceSwitch.new([IceLand::FirstCorridor::BAYS_X[1] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], false),
                              IceSwitch.new([IceLand::FirstCorridor::BAYS_X[2] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], false)
                              )
switchgroup.each {|m| LOCATION.add_active_object m }

# === MONSTERS:

# The nice fair bear who stands on the first corridor
bear = WalkingBear.new([850, 320], 400)
LOCATION.add_sprite(bear)
