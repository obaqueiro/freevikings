# duck.rb
# igneus 15.2.2005

# Prisera neskodna.

module FreeVikings

  class Duck < Sprite

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
      if @counter >= 100
	@counter += 1
      end
    end
  end
end
