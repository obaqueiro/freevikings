# fireballspitter.rb
# igneus 29.1.2009

require 'fireball'

module FreeVikings

  # "Statue", usually built into the wall, which regularly spits fireball.

  class FireballSpitter < Sprite

    include StaticObject

    WIDTH = 40
    HEIGHT = 80
    PAINT_WIDTH = 80
    FBY = 33

    # orientation can be left or right
    def initialize(position, orientation=:right, spit_interval=3)
      super(position)
      @orientation = orientation
      @spit_interval = spit_interval
      @paint_rect = Rectangle.new((orientation == :right ?
                                   @rect.left : @rect.left - WIDTH),
                                  @rect.top,
                                  PAINT_WIDTH,
                                  HEIGHT)

      i = Image.load 'stone_firespitter.png'
      @image = if orientation == :left then
                 i.mirror_x
               else
                 i
               end

      @spitl = TimeLock.new 0
    end

    # unvincible

    def hurt
    end

    def update
      if @spitl.free?
        # spit fireball
        @location << FireBall.new([@rect.left + WIDTH/2-FireBall::WIDTH/2, 
                                   @rect.top + FBY-FireBall::HEIGHT/2], 
                                  @orientation)

        @spitl = TimeLock.new @spit_interval, @location.ticker
      end
    end

    def register_in(loc)
      loc.add_static_object self
      loc.add_sprite self
    end

    def solid?
      true
    end
  end
end
