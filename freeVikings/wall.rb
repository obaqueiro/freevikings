# wall.rb
# igneus 1.11.2008

module FreeVikings

  # Wall is StaticObject made of bricks which may be destroyed
  # (by Erik's head or by a bomb)
  #
  # It has interface of both StaticObject and Sprite, because
  # while normally being a StaticObject, it behaves like a Sprite
  # when it is destroyed (animation) 

  class Wall < Sprite

    include StaticObject

    BRICK_SIZE = 40

    OK, DAMAGED, DISAPPEARING = 2, 1, 0

    def initialize(position, bricks_width, bricks_height)
      super(position)

      @bricks_width = bricks_width
      @bricks_height = bricks_height

      @rect.w = @bricks_width * BRICK_SIZE
      @rect.h = @bricks_height * BRICK_SIZE

      @solid = true

      create_images
    end

    def solid?
      @solid
    end

    # Called when wall is hit by Erik's head or bomb

    def bash
      return unless solid?

      @image = @image_destr
      @solid = false
    end

    private

    def create_images
      s = RUDL::Surface.new [@rect.w, @rect.h]
      r = RUDL::Surface.new [@rect.w, @rect.h]

      @brick = Image.load 'brick.tga'
      @destroyed = Image.load 'brick_destroyed.tga'

      0.upto(@bricks_width) {|col|
        0.upto(@bricks_height) {|row|
          s.blit @brick.image, [col*BRICK_SIZE, row*BRICK_SIZE]
          r.blit @destroyed.image, [col*BRICK_SIZE, row*BRICK_SIZE]
        }
      }

      @image = @image_ok = Image.wrap(s)
      @image_destr = Image.wrap r
    end
  end
end
