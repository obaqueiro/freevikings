# ice_monsters.rb
# igneus 27.6.2005

# Monsters script for location Ice Land

require 'switch'
require 'apple'
require 'killtoy'
require 'bear'

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

  CORRIDOR_HEIGHT = 3 * LOCATION.map.tile_size

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
    FLOOR = 6*LOCATION.map.tile_size
  end # module SecondCorridor

  module ThirdCorridor
    FLOOR = 11 * LOCATION.map.tile_size
    BEGIN_X = 42 * LOCATION.map.tile_size
  end

  module FourthCorridor
    include FreeVikings
    # The corridor before the last.
    # Baleog must help his friend Erik with the bear and the switch.
    # Two arrows through the hole in the wall...
    CEILING = 13 * LOCATION.map.tile_size
    FLOOR = CEILING + CORRIDOR_HEIGHT
    BEGIN_X = 21 * LOCATION.map.tile_size
    END_X = 47 * LOCATION.map.tile_size
  end # module FourthCorridor

  module CorridorToExit
    FLOOR = 21*LOCATION.map.tile_size
    BEGIN_X = 320
    END_X = 1920
  end # module CorridorToExit

  # IceBoard
  # A peace of ice used as a simple trapdoor; a static object
  class IceBoard < Entity
    WIDTH = 80
    HEIGHT = 22

    def initialize(position)
      super(position)
      @rect = Rectangle.new position[0], position[1], WIDTH, HEIGHT
      @image = Image.load('themes/IceTheme/iceboard.tga')
      @solid = true
    end

    attr_reader :rect
    attr_reader :solid

    def image
      @image.image
    end

    def solid?
      @solid
    end

    alias_method :at_least_semisolid?, :solid?
  end # class IceBoard
  
  # A SwitchGroup is a Group of Switches.
  # It's members have all the same update Proc which updates the state of
  # the Group.
  # A SwitchGroup has it's combination of the member switches' states which 
  # means 'open'. All the other combinations mean 'closed'.
  # This combination is given as an argument to the constructor, it should
  # be in form of an Array of true and false values.
  class SwitchGroup < Group

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
        each {|m| LOCATION.add_static_object m}
        @in = true
      end
    end

    def out
      if @in
        each {|m| LOCATION.delete_static_object m}
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

pos = [FirstCorridor::APPLEBAY_X, FirstCorridor::FLOOR]
downshaft_trapdoors = TwoTrapDoors.new(pos)
downshaft_trapdoors.in

pos = [FirstCorridor::END_X - 4*LOCATION.map.tile_size, FirstCorridor::CEILING - IceBoard::HEIGHT]
secondcorridor_trapdoors = TwoTrapDoors.new(pos)
secondcorridor_trapdoors.in

pos = [FourthCorridor::BEGIN_X, FourthCorridor::FLOOR]
trapdoors_to_exit_corridor = TwoTrapDoors.new pos
trapdoors_to_exit_corridor.in

# === ITEMS:

LOCATION.add_item Apple.new([FirstCorridor::APPLEBAY_X + 2*LOCATION.map.tile_size - 0.5*Apple::WIDTH,170])
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
switch = Switch.new([FirstCorridor::APPLEBAY_X + (2 * LOCATION.map.tile_size) - Switch::WIDTH/2, 80], LOCATION.theme, false, appleswitch_proc)
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
                              Switch.new([IceLand::FirstCorridor::BAYS_X[0] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], LOCATION.theme, false),
                              Switch.new([IceLand::FirstCorridor::BAYS_X[1] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], LOCATION.theme, false),
                              Switch.new([IceLand::FirstCorridor::BAYS_X[2] + 40 + 5, FirstCorridor::BAY_SWITCHGROUP_Y], LOCATION.theme, false)
                              )
switchgroup.each {|m| LOCATION.add_active_object m }

# The switch in the third corridor which opens the shaft down for Baleog
# and Olaf
pr = Proc.new {|state| 
  if state then
    downshaft_trapdoors.in
  else
    downshaft_trapdoors.out
  end
}
downshaft_trapdoor_opening_switch = Switch.new([ThirdCorridor::BEGIN_X+4*LOCATION.map.tile_size, ThirdCorridor::FLOOR-2*LOCATION.map.tile_size], LOCATION.theme, true, pr)
LOCATION.add_active_object(downshaft_trapdoor_opening_switch)

# The switch in the fourth corridor.
# It opens Erik the way to freedom and to his friends, but his hand
# isn't long enough to touch it.
pr = Proc.new {
  trapdoors_to_exit_corridor.out  
}
last_eriks_switch = Switch.new([FourthCorridor::END_X+LOCATION.map.tile_size, FourthCorridor::CEILING+LOCATION.map.tile_size+5], LOCATION.theme, false, pr)
LOCATION.add_active_object last_eriks_switch

# === MONSTERS:

# The nice fair bear who stands on the first corridor
bear = WalkingBear.new([FirstCorridor::BEAR_START_X, 320], 400)
LOCATION.add_sprite(bear)

# The bear which Erik must clobber on his own
second_bear = WalkingBear.new([1780, SecondCorridor::FLOOR - WalkingBear::HEIGHT], 230)
LOCATION.add_sprite second_bear

# The bear from the fourth corridor
floor_begin_x = FourthCorridor::BEGIN_X + 3 * LOCATION.map.tile_size
floor_length = FourthCorridor::END_X - floor_begin_x
center_x = floor_begin_x + floor_length / 2
bear_from_c4 = WalkingBear.new([center_x, FourthCorridor::FLOOR - WalkingBear::HEIGHT], floor_length/2 * 3/5)
LOCATION.add_sprite bear_from_c4

# Bears in the last corridor. Just for fun for Baleog.
center = CorridorToExit::BEGIN_X + ((CorridorToExit::END_X - CorridorToExit::BEGIN_X) / 2)
trace_length = (center - CorridorToExit::BEGIN_X) - 100 - 30
y = CorridorToExit::FLOOR - WalkingBear::HEIGHT
exitbear_1 = WalkingBear.new([center - 100, y], trace_length)
exitbear_2 = WalkingBear.new([center + 100, y], trace_length)
LOCATION.add_sprite exitbear_1
LOCATION.add_sprite exitbear_2
