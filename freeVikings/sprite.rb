# sprite.rb
# igneus 19.1.2004

# Tridy sprajtu pro hru FreeVikings

require 'RUDL'

require 'velocity.rb'
require 'imagebank.rb'

module FreeVikings

  class Sprite
    # Trida pohyblivych objektu (typicky postavicek)

    BASE_VELOCITY = 135

    attr_reader :moving

    def initialize
      @image = Image.new('baleog.png')
      @top = 60
      @left = 70
      @moving = nil
      @velocity_horis = Velocity.new
      @velocity_vertic = Velocity.new
    end

    def paint(surface)
      surface.blit(@image, coordinate_in_surface(surface))
    end

    # Vrati vzdalenost od vrsku

    def top
      @top
    end

    # Vrati vzdalenost odleva

    def left
      @left
    end

    def image
      @image.image
    end

    def move_left
    end

    def move_right
    end

    def stop
      @moving = nil
    end

    private
    def coordinate_in_surface(surface)
      coordinate = Array.new
      coordinate[0] = left() % surface.w
      coordinate[1] = top() % surface.h
      return coordinate
    end

  end # class

end # module
