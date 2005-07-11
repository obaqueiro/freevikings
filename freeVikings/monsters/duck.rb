# duck.rb
# igneus 15.2.2005

# Prisera neskodna.

require 'monster.rb'

module FreeVikings

  class Duck < Sprite

    include Monster

    def initialize
      super [100,80]
      @image = Image.load('duck_left.tga')
      @counter = 0
    end

    def image
      @image.image
    end

    def update
    end
  end
end
