# bridge.rb
# igneus 19.6.2005

# A bridge for the vikings.

require 'platform'

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

    def initialize(left, *ys)
      @y = ys
      super([left, @y[0], WIDTH, HEIGHT])
      @velocity = Velocity.new 8
      @last_update = Time.now.to_i
    end

    def next
      @y.push @y.shift
    end

    def update
      if @rect.top != @y.first then
        delta = @velocity.value * (Time.now.to_i - @last_update)
        delta = 1 if delta < 10
        delta *= -1 if @y.first - @y.last < 0
        @rect.top += delta
      end
      @last_update = Time.now.to_i
    end
  end # class FallingBridge
end # module FreeVikings
