# duck.rb
# igneus 15.2.2005

# Prisera neskodna.

require 'monster.rb'

module FreeVikings

  class Duck < Sprite

    include Monster

    def initialize
      @image = Image.new('duck_left.tga')
      @counter = 0
      @top = 17
    end

    def image
      @image.image
    end

    def left
      100
    end

    def top
      80
    end

    def update
    end
  end
end
