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
require 'map'

# === CONSTANTS:

module IceLand

  include FreeVikings

  DEBUG = false

  def IceLand.dbg(text)
    if DEBUG
      print '///'
      puts text
    end
  end

  CORRIDOR_HEIGHT = 3 * FreeVikings::Map::TILE_SIZE

  module FirstCorridor
    CEILING = 280
    FLOOR = CEILING + CORRIDOR_HEIGHT
    END_X = 1480
    APPLEBAY_X = 320
    BAY_SWITCHGROUP_Y = 230
    BAYS_X = [640, 840, 1040]
    BEAR_START_X = 850
  end # module FirstCorridor

  module SecondCorridor
    FLOOR = 6*FreeVikings::Map::TILE_SIZE
  end # module SecondCorridor

  module FourthCorridor
    include FreeVikings
    # The corridor before the last.
    # Baleog must help his friend Erik with the bear and the switch.
    # Two arrows through the hole in the wall...
    CEILING = 13 * Map::TILE_SIZE
    FLOOR = CEILING + CORRIDOR_HEIGHT
    END_X = 47 * Map::TILE_SIZE
  end # module FourthCorridor

  module CorridorToExit
    FLOOR = 21*FreeVikings::Map::TILE_SIZE
    BEGIN_X = 320
    END_X = 1920
  end # module CorridorToExit

  # IceBoard
  # A peace of ice used as a simple trapdoor; a static object
  class IceBoard
    WIDTH = 80
    HEIGHT = 22
    def initialize(position)
      @rect = FreeVikings::Rectangle.new position[0], position[1], WIDTH, HEIGHT
      @image = FreeVikings::Image.load('ice_map/iceboard.tga')
      @solid = true
    end
    attr_reader :rect
    attr_reader :solid
    def image
      @image.image
    end
  end # class IceBoard
  
  SWITCH_GFX = {'true' => Image.load('ice_map/ice_switch_on.tga'),
                'false' => Image.load('ice_map/ice_switch_off.tga')}

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
      serve_shield_collision {
        if @state.direction == 'left' then
          move_right
        else
          move_left
        end

        new_walk_length
      }
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
      IceLand.dbg "#{@state.direction} #{n}"
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
      IceLand.dbg 'Switchgroup update.'
      @combination.size.times do |i|
        if @members[i] and @combination[i] == @members[i].state then
          next
        else
          open = false
          @proc.call open
          return
        end
      end
      open = true
      @proc.call open
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

  class TrapDoorGroup < Array
    def initialize(*members)
      self.concat members
      @in = false
    end

    def in
      unless @in
        each {|m| LOCATION.map.static_objects.add m}
        @in = true
      end
    end

    def out
      if @in
        each {|m| LOCATION.map.static_objects.delete m}
        @in = false
      end
    end
  end # class TrapDoorGroup

  class TwoTrapDoors < TrapDoorGroup
    def initialize(position)
      temp = []
      2.times do |i|
        x = position[0] + i*IceBoard::WIDTH
        y = position[1]
        temp << IceBoard.new([x, y])
      end
      super temp[0], temp[1]
    end
  end # class TwoTrapDoors
end # module IceLand


include FreeVikings
include IceLand


# === STATIC OBJECTS:
pos = [FirstCorridor::APPLEBAY_X, FirstCorridor::CEILING-IceBoard::HEIGHT]
applebay_trapdoors = TwoTrapDoors.new(pos)
applebay_trapdoors.in

pos = [FirstCorridor::APPLEBAY_X, FirstCorridor::FLOOR + 1]
downshaft_trapdoors = TwoTrapDoors.new(pos)
downshaft_trapdoors.in

pos = [FirstCorridor::END_X - 4*Map::TILE_SIZE, FirstCorridor::CEILING - IceBoard::HEIGHT]
secondcorridor_trapdoors = TwoTrapDoors.new(pos)
secondcorridor_trapdoors.in


# === ITEMS:

LOCATION.add_item Apple.new([FirstCorridor::APPLEBAY_X + 2*Map::TILE_SIZE - 0.5*Apple::WIDTH,170])
LOCATION.add_item Killtoy.new([985, 330])

# === ACTIVE OBJECTS:

# The first switch in the first corridor. Erik can reach it only with 
# Olaf's help. It does nothing.
appleswitch_proc = Proc.new do |switch_state|
  if switch_state then
    secondcorridor_trapdoors.out
  else
    secondcorridor_trapdoors.in
  end
end
switch = Switch.new([FirstCorridor::APPLEBAY_X + (2 * Map::TILE_SIZE) - Switch::WIDTH/2, 80], false, appleswitch_proc, IceLand::SWITCH_GFX)
LOCATION.add_active_object switch

# The group of three switches over the first corridor. Erik can reach every 
# of them.
swtchgrp_update_proc = Proc.new do |switchgroup_state|
  if switchgroup_state then
    applebay_trapdoors.out
  end
end
switchgroup = SwitchGroup.new(
                              [false, true, true],
                              swtchgrp_update_proc,
                              IceSwitch.new([IceLand::FirstCorridor::BAYS_X[0] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], false),
                              IceSwitch.new([IceLand::FirstCorridor::BAYS_X[1] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], false),
                              IceSwitch.new([IceLand::FirstCorridor::BAYS_X[2] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], false)
                              )
switchgroup.each {|m| LOCATION.add_active_object m }

# The switch in the fourth corridor.
# It opens Erik the way to freedom and to his friends, but his hand
# isn't long enough to touch it.
last_eriks_switch = Switch.new([FourthCorridor::END_X+Map::TILE_SIZE, FourthCorridor::CEILING+Map::TILE_SIZE+5], false, Proc.new{}, IceLand::SWITCH_GFX)
LOCATION.add_active_object last_eriks_switch

# === MONSTERS:

# The nice fair bear who stands on the first corridor
bear = WalkingBear.new([FirstCorridor::BEAR_START_X, 320], 400)
LOCATION.add_sprite(bear)

# The bear which Erik must clobber on his own
second_bear = WalkingBear.new([1780, SecondCorridor::FLOOR - Bear::HEIGHT], 230)
LOCATION.add_sprite second_bear

# Bears in the last corridor. Just for fun for Baleog.
center = CorridorToExit::BEGIN_X + ((CorridorToExit::END_X - CorridorToExit::BEGIN_X) / 2)
trace_length = (center - CorridorToExit::BEGIN_X) - 100 - 30
y = CorridorToExit::FLOOR - Bear::HEIGHT
exitbear_1 = WalkingBear.new([center - 100, y], trace_length)
exitbear_2 = WalkingBear.new([center + 100, y], trace_length)
LOCATION.add_sprite exitbear_1
LOCATION.add_sprite exitbear_2
