# boat.rb
# igneus 17.9.2008

require 'transporter'
require 'rudlmirror.rb'

module FreeVikings

  # It's a regular 'flying platform' which moves horizontally between two 
  # (or more)
  # points and looks like ship.

  class Boat < Sprite

    include StaticObject
    include Transporter

    WIDTH = 120 #160
    HEIGHT = 30 #60

    VELOCITY = 60

    # ys is Array of x-positions of boats end points

    def initialize(pos, xs)
      super(pos)
      @paint_rect = RelativeRectangle.new(@rect, -20, -30, 40, 30)
      @xs = xs
      @dest = 0 # index of next x
      init_transporter
    end

    # Boat has graphic_rect and paint_rect different!
    # (It is the first class which has ever had it...)

    attr_reader :paint_rect

    def register_in(loc)
      loc.add_sprite self
      loc.add_static_object self
    end

    # Boat behaves as both Sprite and StaticObject.

    def solid?
      true
    end

    def state
      if @rect.right <= @xs[@dest] then
        return 'right'
      else
        return 'left'
      end
    end

    def update
      delta_x = @location.ticker.delta * VELOCITY

      if state == 'right' then
        # Destination reached
        if (@rect.right + delta_x) >= @xs[@dest] then
          delta_x = @xs[@dest] - @rect.right
          next_dest
        end
      else
        delta_x *= -1

        # Destination reached
        if (@rect.left + delta_x) <= @xs[@dest] then
          delta_x = @xs[@dest] - @rect.left
          next_dest
        end
      end

      @rect.left += delta_x
      # @paint_rect.left += delta_x

      update_transported_sprites delta_x, 0
    end

    def init_images
      right = Image.load 'boat_right.tga'
      left = Image.wrap right.image.mirror_x
      @image = Model.new({'left' => left, 'right' => right})
    end

    private

    # Selects next destination

    def next_dest
      if @dest+1 < @xs.size then
        @dest += 1
      else
        @dest = 0
      end
    end
  end
end
