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

    OK, DISAPPEARING, KO = 2, 1, 0

    def initialize(position, bricks_width, bricks_height, location)
      super(position)

      @location = location

      @bricks_width = bricks_width
      @bricks_height = bricks_height

      @rect.w = @bricks_width * BRICK_SIZE
      @rect.h = @bricks_height * BRICK_SIZE

      @state = OK

      create_images
    end

    def solid?
      @state != KO
    end

    # Called when wall is hit by Erik's head or bomb

    def bash
      return unless solid?

      @state = DISAPPEARING
      @destroy_brick = 0
      @destroy_time = Time.now.to_f

      @location.add_sprite self
    end

    def update
      time_since_bash = Time.now.to_f - @destroy_time

      while (time_since_bash / 0.3) > @destroy_brick do
        if (@destroy_brick < num_bricks) then
          @image.image.blit @damaged.image, brick_coordinates(@destroy_brick)
        end
        if ((@destroy_brick - 1) <= num_bricks) &&
            ((@destroy_brick - 1) >= 0) then
          @image.image.blit @destroyed.image, brick_coordinates(@destroy_brick-1)
        end
        @destroy_brick += 1
      end

      if @destroy_brick > num_bricks then
        @state = KO
        @location.delete_sprite self
      end
    end

    # Accepts brick's index, returns it's coordinates [relative to Wall's
    # rectangle]

    def brick_coordinates(i)
      if i < 0 then
        raise ArgumentError, "Index must be equal or greater to 0."
      end
      if i >= num_bricks then
        raise ArgumentError, "Index out of range: Wall has '#{num_bricks}' bricks."
      end

      return [(i % @bricks_width) * BRICK_SIZE,
              (i / @bricks_width) * BRICK_SIZE]
    end

    def num_bricks
      @bricks_width * @bricks_height
    end

    private

    def create_images
      s = RUDL::Surface.new [@rect.w, @rect.h]

      @brick = Image.load 'brick.png'
      @damaged = Image.load 'brick_damaged.png'
      @destroyed = Image.load 'brick_destroyed.tga'

      0.upto(@bricks_width) {|col|
        0.upto(@bricks_height) {|row|
          s.blit @brick.image, [col*BRICK_SIZE, row*BRICK_SIZE]
        }
      }

      @image = Image.wrap(s)
    end
  end
end
