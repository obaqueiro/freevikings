# holyhole_script.rb
# 12.12.2008

require 'wall'
require 'ladder'
require 'runestone'
require 'textbox'
require 'helpbutton'
require 'apple'
require 'lock'
require 'key'
require 'door'
require 'switch'
require 'bridge'
require 'bomb'
require 'fallingstone'

# Stone which can be read by vikings (some runic text is written on it)
class SpeakingStone < ActiveObject
  WIDTH = 60; HEIGHT = 80

  def initialize(pos, text)
    super(pos)
    @text = text
  end

  def activate(who=nil)
    if @textbox and @textbox.in? then
      deactivate
    else
      @textbox = DisappearingTextBox.new([@rect.left-60,@rect.top-60],
                                         @text, 6)
      LOCATION << @textbox
    end
  end

  def deactivate(who=nil)
    if @textbox then
      @textbox.disappear
      @textbox = nil
    end
  end

  def init_images
    @image = Image.load 'runestone.png'
    writing = Image.new 'locs/Christmas2008/HolyHole/runestone_writing.png'
    @image.image.blit writing.image, [20,10]
  end
end

TS = LOCATION.map.tile_size

# Stone at the HOLE
stone_pos = [30*TS, 14*TS-RuneStone::HEIGHT]
LOCATION << SpeakingStone.new(stone_pos,
                              "Runic text on the stone says: This is Odin's Holy Hole. Whoever jumps into it, either dies or gains wisdom, strength and wealth.")
LOCATION << HelpButton.new([stone_pos[0]-60, stone_pos[1]+20],
                           "To read runic text on the stone, go to it and press 'S'.",
                           LOCATION)

# Apples in the "secret apple chamber":
apple_pos = [42*TS, 24*TS]
3.times {|i| 
  LOCATION << Apple.new([apple_pos[0]+i*TS, apple_pos[1]])
}

# Walls and bombs in the secret "bonus way"
LOCATION << Wall.new([17*TS, 33*TS], 6, 1, LOCATION)
LOCATION << Wall.new([16*TS, 42*TS], 1, 3, LOCATION)

4.times {|i|
  LOCATION << Bomb.new([(25+i)*TS,32*TS])
}

# Ladder in the big cave
LOCATION << Ladder.new([46*TS,61*TS], 13)

# Lock on the "island between apexes" and key on the top of ladder
# (lock, when unlocked, makes path to the door; switch opens the door);
LOCATION << (door = Door.new([25*TS,72*TS]))
LOCATION << Switch.new([44*TS,73*TS+10], LOCATION.theme, 
                       false, Proc.new{door.open})
LOCATION << Lock.new([37*TS-Lock::WIDTH/2,73*TS],
                     Proc.new {
                       3.times {|i|
                         LOCATION << Bridge.new([(26+3*i)*TS,75*TS],
                                                LOCATION.theme)
                       }
                     },
                     Lock::BLUE)
LOCATION << Key.new([46*TS+20, 60*TS], Key::BLUE)

# Ladders to the exit
LOCATION << Ladder.new([3*TS, 45*TS], 14)
LOCATION << Ladder.new([13*TS, 59*TS], 7)
LOCATION << Ladder.new([3*TS, 66*TS], 9)

# Falling stones
LOCATION << FallingStoneEmitter.new([9*TS,60*TS])
LOCATION << FallingStoneEmitter.new([14*TS,53*TS], 12.0)
