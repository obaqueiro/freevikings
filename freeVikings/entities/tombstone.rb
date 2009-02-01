# tombstone.rb
# igneus 15.6.2005

# When a monster is killed, instead of it's corpse a nice tombstone
# appears (and it disappears soon, too).
# FreeVikings aren't a bloody game...

# RIP == REQUIESCAT IN PACE == I wish he would rest in peace

module FreeVikings

  class Tombstone < Sprite

    HEIGHT = 50
    WIDTH = 50

    FRAMES = 8
    FRAME_TIME = 0.2 # in seconds

    def initialize(initial_position)
      pos = initial_position
      if pos.is_a? Rectangle then
        pos.top += pos.h - HEIGHT
      end
      pos.w = WIDTH
      pos.h = HEIGHT

      super pos

      @state = 0

      @anim_lock = TimeLock.new(FRAME_TIME)
    end

    def hurt
      nil
    end

    def update
      return unless @anim_lock.free?

      @state += 1

      if @state >= FRAMES then
        destroy
        return
      end

      @image = @images[@state]
      @anim_lock.reset
    end

    def init_images
      frnames = %w(1 2 3 4 5 6)
      tombstone = SpriteSheet.load2('tombstone.png', 50, 50, frnames)
      
      @images = frnames.collect {|n| tombstone[n] }
      @images.concat [Image.load('puff_cloud1.tga'),
                      Image.load('puff_cloud2.tga')]

      @image = @images[0]
    end
  end # class Tombstone
end # module FreeVikings
