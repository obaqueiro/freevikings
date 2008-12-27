# happylend_script.rb
# igneus 22.12.2008

require 'ladder'
require 'present'
require 'apple'
require 'killtoy'
require 'bomb'
require 'penguin'
require 'switch'
require 'troll'
require 'flyingtroll'

require 'talkable'
require 'talk'

TS = LOCATION.map.tile_size
$unpacked_presents = 0

# classes, methods ===========================================================

# Present modified so that it keeps track od fow many pieces have been unpacked

class FreeVikings::Present

  alias_method :_apply, :apply
  def apply(who)
    $unpacked_presents += 1
  end
end

# "Thor, vikings' god of thunder"

class Thor < Sprite

  FAVOURITE_COLOUR = [150,70,70]

  include Talkable

  def initialize(position)
    super(position)
    @state = :watching_vikings

    @talk1 = Talk.new(File.open('locs/Christmas2008/HappyLEnd/thors_preaching.yaml'))
    @talk2 = Talk.new(File.open('locs/Christmas2008/HappyLEnd/thor_wants_sacrifice.yaml'))
  end

  def update
    case @state
    when :watching_vikings
      if ! defined?(@waitlock) || @waitlock.free? then
        if presents_unpacked? then
          move_to_active
          @talk1.start(self, @location.team.active)
          @location.talk = @talk1
          @state = :angry_speaking
        end
        @waitlock = TimeLock.new 5
      end
    when :angry_speaking
      if @talk1.talk_completed? then
        @state = :wait_for_sacrifice
      end
      put_trolls
    when :wait_for_sacrifice
      if trolls_killed? then
        move_to_active
        @talk2.start(self, @location.team.active)
        @location.talk = @talk2

        @state = :wait_for_a_while
        @waitlock = TimeLock.new 3, @location.ticker
      end
    when :wait_for_a_while
      return unless @waitlock.free?
      @state = :exit_speech
    when :exit_speech then
      if @talk2.talk_completed? then
        @location << Ladder.new([28*TS,3*TS], 14)
        destroy
      end
    end
  end

  def move_to_active
    r = @location.team.active.rect
    @rect.left = r.left
    @rect.top = r.top - 150
  end

  def presents_unpacked?
    @location.items_on_rect(@location.map.rect) {|i|
      if i.is_a? Present then
        return false
      end
    }
    @location.team.each {|v|
      v.inventory.each {|i|
      if i.is_a? Present then
        return false
      end
      }
    }
    return true
  end

  def put_trolls
    y = 17*TS-Troll::HEIGHT
    p1 = [:repeat, -1, [[:go, 8*TS],
                        [:go, 19*TS],
                        [:wait, 2],
                        [:go, 27*TS],]]
    p2 = [:repeat, -1, [[:go, [20*TS,14*TS]],
                        [:shoot],
                        [:go, [20*TS, 2*TS]],
                        [:go, [24*TS, 14*TS]],
                        [:go, [27*TS, 14*TS]]]]
    @trolls = [
               Troll.new([8*TS,y], p1),
               Troll.new([16*TS,y], p1), 
               Troll.new([24*TS,y], p1),
               FlyingTroll.new([11*TS,10*TS], p2),
               FlyingTroll.new([27*TS,10*TS], p2)
              ]
    @trolls.each {|t| @location << t}
  end

  def trolls_killed?
    @trolls.each {|t| return false if t.alive? }
    return true
  end

  def init_images
    @image = Image.new
  end
end

# Blinking lights on the tree

class TreeLights < Sprite

  MODES = [:on, :off, :blink]
  BLINK_PERIOD = 1.0

  def initialize(*positions)
    super(positions.shift)
    @lights = []
    i = 0
    positions.each {|p|
      @lights << Light.new(p, Light::COLOURS[(i/2)%3], self)
      i += 1
    }
    @mode = :on
  end

  def switch_mode
    @mode = MODES[(MODES.index(@mode)+1) % MODES.size]

    case @mode
    when :on
      set_lights Light::FULL
    when :off
      set_lights Light::NO
    when :blink
      @blink_state = Light::FULL
      set_lights @blink_state
      @blink_d = 1 # always 1 or -1
      @blink_timer = TimeLock.new(BLINK_PERIOD, @location.ticker)
    end
  end

  def update
    if @mode == :blink && @blink_timer.free? then
      if (@blink_state + @blink_d) > Light::NO ||
          (@blink_state + @blink_d) < Light::FULL then
        @blink_d *= -1
      end
      @blink_state = (@blink_state + @blink_d)
      set_lights @blink_state

      delay = if @blink_state == Light::FULL || @blink_state == Light::NO then
                BLINK_PERIOD
              else
                BLINK_PERIOD / 2
              end
      @blink_timer = TimeLock.new(delay, @location.ticker)
    end
  end

  def set_lights(i)
    @lights.each {|l| l.light = i }
  end

  def register_in(loc)
    @lights.each {|l|
      loc.add_active_object l
    }
    loc.add_sprite self
  end

  # Called by light when it is switched - e.g. hit by arrow

  def delete(light)
    @lights.delete light
    @location.delete_active_object light
  end

  def image
    @my_light.image
  end

  def init_images
    @my_light = Light.new(@rect, :yellow, self)
  end

  class Light < ActiveObject

    COLOURS = [:yellow, :red, :green]

    # colour: :yellow, :red, :green
    def initialize(pos, colour, master)
      @colour = colour
      @master = master
      super(pos)
    end

    NO,SMALL,HALF,FULL = 3,2,1,0

    def light=(i)
      @image = @spritesheet[i]
    end

    def activate(who)
      @master.delete self
    end

    alias_method :deactivate, :activate

    def init_images
      y = case @colour
          when :yellow
            0
          when :red
            9
          when :green
            18
          else
            raise "Unknown colour '#{@colour}'"
          end

      frames = {}
      0.upto(2) {|i|
        frames[i] = R(i*9, y, 9, 9)
      }
      frames[3] = R(2*9, 3*9, 9, 9)

      @spritesheet = SpriteSheet.load('christmas_tree_lights.png', frames)
      @image = @spritesheet[0]
    end
  end
end

# content ====================================================================

### Thor
LOCATION << Thor.new([25*TS, 7*TS])

### Ladder
LOCATION << Ladder.new([50, 9*TS], 10)

### Lights on the tree
tree_rect = R(19*TS, 0, 5*TS, 14*TS)
light_positions = []
tree_rect.top.step(tree_rect.bottom, TS) {|branch_level|
  5.times {|i|
    next if i == 2

    # don't pu lights on missing branches
    next if (branch_level == 2*TS || branch_level == 10*TS) && i > 2
    next if branch_level == 7*TS && i < 2

    light_positions << [tree_rect.left + i*TS+rand(TS/2),
                        branch_level + (i==1 || i==3 ? 0 : 12)]
  }
}

tree_lights = TreeLights.new(*light_positions)
LOCATION << tree_lights

# switch which changes mode of the lights
LOCATION << Switch.new([16*TS,15*TS], LOCATION.theme, true, 
                       Proc.new { tree_lights.switch_mode })

### Presents under the tree
tree_pos = [21.5*TS, 17*TS]
gift_radius = 300

# items and actions to be packed as Christmas presents:
gifts = [
         Proc.new {|viking| 
           viking.location << Penguin.new([viking.rect.left-80,
                                           viking.rect.bottom-Penguin::HEIGHT])
         }
        ]
4.times { gifts << Apple.new([0,0]) }
2.times { gifts << Killtoy.new([0,0]) }
3.times { gifts << Bomb.new([0,0]) }

# pack presents and put them around the tree:
gifts.each {|g|
  y = tree_pos[1]-Present::HEIGHT
  x = tree_pos[0] + (rand(gift_radius*2) - gift_radius)
  pos = [x,y]

  if g.is_a? Item then
    p = ItemPresent.new(pos, g)
  elsif g.is_a? Proc then
    p = ActionPresent.new(pos, g)
  else
    raise "Unsupported present type '#{g.class}'"
  end
  LOCATION << p
}

### cONVERSATION AT THE EXIT:
LOCATION.on_exit = Proc.new do
  if LOCATION.team.alive_size == LOCATION.team.size
    t = Talk.new(File.open('locs/Christmas2008/HappyLEnd/final_talk.yaml'))
    team = LOCATION.team
    t.start team['erik'], team['baleog'], team['olaf']
    LOCATION.talk = t
  end
end
