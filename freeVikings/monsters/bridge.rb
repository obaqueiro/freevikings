# bridge.rb
# igneus 19.6.2005

# A bridge for the vikings.

require 'platform'
require 'sprite.rb'

module FreeVikings

  class Bridge < Sprite

    include Platform

    def init_images
      @image = Image.new 'yellow_map/small_bridge.tga'
    end
  end # class Bridge

  class FallingBridge < Bridge

    WIDTH = 80
    HEIGHT = 24
    VELOCITY = 13

    def initialize(left, *ys)
      @y = ys
      super([left, @y[0], WIDTH, HEIGHT])
      @velocity = Velocity.new VELOCITY
    end

    def next
      @y.push @y.shift
    end

    def update
      if @rect.top != @y.first then
        delta = @velocity.value * @location.ticker.delta
        delta = 1 if delta < (VELOCITY + 5)
        delta *= -1 if @y.first - @y.last < 0
        @rect.top += delta
      end
    end
  end # class FallingBridge
end # module FreeVikings
