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

    # ys is Array of x-positions of boats end points

    def initialize(pos, xs)
      super(pos)
      @xs = xs
      @dest = 0 # index of next x
      init_transporter
    end

    def register_in(loc)
      loc.add_sprite self
      loc.add_static_object self
    end

    def state
      if @rect.right <= @xs[@dest] then
        return 'right'
      else
        return 'left'
      end
    end

    def update
      update_transported_sprites
    end

    def init_images
      right = Image.load 'boat_right.tga'
      left = Image.wrap right.image.mirror_x
      @image = Model.new({'left' => left, 'right' => right})
    end
  end
end
