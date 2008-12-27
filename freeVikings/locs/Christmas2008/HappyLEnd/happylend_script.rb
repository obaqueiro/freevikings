# happylend_script.rb
# igneus 22.12.2008

require 'ladder'
require 'present'
require 'apple'
require 'killtoy'
require 'bomb'
require 'penguin'

require 'talkable'

TS = LOCATION.map.tile_size

class Thor < Sprite

  include Talkable

  def update
    if ! defined?(@waitlock) || @waitlock.free? then
      if presents_unpacked? then
        get_angry
      end
      @waitlock = TimeLock.new 5
    end
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

  def get_angry
    # move to the vikings so that they can hear
    ar = @location.team.active.rect
    @rect.left = ar.left
    @rect.top = ar.top - 140

    say("I'm Thor, vikings' god of thunder. I'm really angry with you, guys.")
  end

  def init_images
    @image = Image.new
  end
end

LOCATION << Thor.new([25*TS, 7*TS])

LOCATION << Ladder.new([50, 9*TS], 10)

### Presents under the tree
tree_pos = [21.5*TS, 17*TS]
gift_radius = 350

# items and actions to be packed as Christmas presents:
gifts = [
         Killtoy.new([0,0]),
         Bomb.new([0,0]),
         Proc.new {|viking| 
           viking.location << Penguin.new([viking.rect.left,
                                           viking.rect.bottom-Penguin::HEIGHT])
         }
        ]
4.times { gifts << Apple.new([0,0]) }

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
