# tombstone.rb
# igneus 15.6.2005

# When a monster is killed, instead of it's corpse a nice tombstone
# appears (and it disappears soon, too).
# FreeVikings aren't a bloody game...

# RIP == REQUIESCAT IN PACE == I wish he would rest in peace

require 'sprite.rb'

module FreeVikings

  class Tombstone < Sprite

    TIME_OF_EXISTENCY = 3

    HEIGHT = 50
    WIDTH = 50

    STATES = [['stone', 'tombstone.tga', 3], 
              ['puff1', 'puff_cloud1.tga', 0.5],
              ['puff2', 'puff_cloud2.tga', 0.5]]

    def initialize(initial_position)
      pos = initial_position
      if pos.size >= 4 then
        pos.top += pos.h - HEIGHT
      end
      pos.w = WIDTH
      pos.h = HEIGHT
      super pos
      init_images
      @appear_time = Time.now.to_i
      @state = 0
    end

    def hurt
      nil
    end

    def update
      if Time.now.to_i >= @appear_time + STATES[@state][2] then
        @appear_time += STATES[@state][2]
        @state += 1
      end
      destroy if @state == STATES.size
    end

    def state
      STATES[@state][0]
    end

    private

    def init_images
      @image = ImageBank.new self
      STATES.each do |s|
        @image.add_pair s[0], Image.new(s[1])
      end
    end
  end # class Tombstone
end # module FreeVikings
