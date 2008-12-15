# fallingstone.rb
# igneus 15.12.2008

module FreeVikings

  # Sprite with empty image; regularly emits falling stones.

  class FallingStoneEmitter < Sprite

    WIDTH=HEIGHT=40

    # interval is in seconds

    def initialize(position, interval=3.5, stone_velocity=80.0)
      super(position)
      @image = Image.wrap(RUDL::Surface.new([1,1]))
      @interval = interval
      @velo = stone_velocity
    end

    def update
      unless @emit_lock
        @emit_lock = TimeLock.new @interval, @location.ticker
      end

      if @emit_lock.free? then
        @emit_lock = TimeLock.new @interval, @location.ticker
        emit_stone
      end
    end

    private

    def emit_stone
      @location << FallingStone.new([@rect.left+WIDTH/2-FallingStone::WIDTH/2,
                                   @rect.top+HEIGHT/2-FallingStone::HEIGHT/2],
                                    @velo)
    end
  end

  # Falling stone which kills viking if it falls on his head :)

  class FallingStone < Sprite

    WIDTH = HEIGHT = 36

    DEFAULT_Z_VALUE = 120

    def initialize(position, velocity=70.0)
      super(position)
      @velocity = velocity
      @collision_rect = @rect
      @paint_rect = RelativeRectangle.new(@rect, -2,-2,4,4)
    end

    attr_reader :paint_rect
    attr_reader :collision_rect

    def update
      # kill heroes
      @location.heroes_on_rect(@rect) {|h|
        h.destroy
      }

      # try to move
      n = next_pos
      if @location.area_free?(n) &&
          (Viking.shield==nil || !n.collides?(Viking.shield.rect)) then
        @rect.top = n.top
      else
        @location.delete_sprite self
      end
    end

    def init_images
      @image = Image.load 'stone_40x40.png'
    end

    private

    def next_pos
      @rect.move(0, (@velocity*@location.ticker.delta).to_i)
    end
  end
end
