# ladder.rb
# igneus 16.11.2008

module FreeVikings

  # Ladder is a game object which enables vikings to climb up.

  class Ladder < ActiveObject

    include StaticObject

    WIDTH = 80
    BIT_HEIGHT = 40

    # position:: Rectangle or Array; even if Rectangle is given,
    #            only position of top left corner will be taken
    #            into consideration.
    #            Width and height of the Ladder is assigned programatically!
    # bits:: length of Ladder in bits (bit height is stored in
    #        Ladder::BIT_HEIGHT)

    def initialize(position, bits)
      super(position)

      @rect = Rectangle.new(position[0], position[1], 
                            WIDTH, bits * BIT_HEIGHT)

      create_image(bits)
    end

    def solid?
      false
    end

    def semisolid?
      true
    end

    def activate(who)
      who.climb(self, :up)
    end

    def deactivate(who)
      who.climb(self, :down)
    end

    def register_in(l)
      l.add_static_object self
      l.add_active_object self
    end

    private

    def create_image(bits) 
      bit = Image.load 'ladder_bit.tga'

      s = RUDL::Surface.new([WIDTH, bits*BIT_HEIGHT])
      fuchsia = [255,0,255]
      s.fill fuchsia
      s.set_colorkey fuchsia

      0.upto(bits) {|i|
        s.blit bit.image, [0, i*BIT_HEIGHT]
      }
      @image = Image.wrap s
    end
  end
end
