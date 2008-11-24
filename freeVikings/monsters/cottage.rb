# cottage.rb
# igneus 23.9.2008

module FreeVikings

  # Cottage is a very simple, by default non-solid  StaticObject

  class Cottage < Entity

    WIDTH = HEIGHT = 200

    include StaticObject

    # Argument 'owner' is optional - it should be a short name, because it
    # will be written over the door...

    def initialize(pos, owner='')
      @owner = owner
      super(pos)
    end

    def semisolid?
      true
    end

    def init_images
      @image = Image.load 'cottage.tga'

      if @owner != '' then
        @image.image.print [73,61], @owner, [255,255,255]
      end
    end
  end
end
