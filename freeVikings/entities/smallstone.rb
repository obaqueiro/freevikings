# smallstone.rb
# igneus 22.12.2008

require 'monstermixins'

module FreeVikings

  # SmallStone is a piece of stone which appears somewhere and
  # flies with given velocity and angle (so it doesn't move
  # constantly as most sprites do).

  class SmallStone < Sprite

    WIDTH = HEIGHT = 20

    include MonsterMixins::HeroBashing
    include MonsterMixins::ShieldSensitive

    @@bash_delay = 1.5

    # velocity:: in pixels per second
    # angle::    in radians

    def initialize(position, velocity, angle)
      super(position)
      @initial_position = @rect.dup

      @velocity = velocity
      @angle = angle

      @gravity = FreeVikings::GRAVITY
    end

    def update
      unless @start_time
        @start_time = @location.ticker.now
        return
      end

      if stopped_by_shield? then
        destroy
        return
      end

      bash_heroes

      t = @location.ticker.now - @start_time
      x = @initial_position.left + @velocity*t*Math.cos(@angle)
      y = @initial_position.top - @velocity*t*Math.sin(@angle) + 0.5*@gravity*(t**2)

      unless @location.area_free?(Rectangle.new(x,y,WIDTH,HEIGHT))
        destroy
        return
      end

      @rect.left = x; @rect.top = y
    end

    def init_images
      @image = Image.load 'stone_40x40.png'
      @image = Image.wrap @image.image.zoom(0.5, 0.5, true)
    end

    private

    def new_pos

    end
  end
end
