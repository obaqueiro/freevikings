# bigbrick.rb
# igneus 9.2.2009

module FreeVikings

  # Big grey brick which can be pulled by the vikings.
  # It can be added into the Location as a Sprite - then it falls down.

  class BigBrick < Sprite

    include StaticObject

    WIDTH = HEIGHT = 80

    # 'z' must be higher than Vikings', because objects are painted
    # in order given by their 'z' and anything than is pulled must be
    # painted after vikings
    DEFAULT_Z_VALUE = 110

    FALL_SPEED = 100

    def initialize(pos)
      super(pos)

      # used to test for possibility of falling
      @fall_rect = Rectangle.new(@rect.left+2,@rect.bottom,@rect.w-4,@rect.h/2)

      # used to test if next position is free
      @test_rect = Rectangle.new(0,0,@rect.w,@rect.h)
    end

    def solid?
      true
    end

    def pull(new_x)
      @test_rect.top = @rect.top

      if new_x < @rect.left
        @test_rect.left = new_x
        @test_rect.w = @rect.left - new_x - 1
      else
        @test_rect.left = @rect.right + 1
        @test_rect.w = new_x - @rect.left - 1
      end

      unless @location.area_free?(@test_rect)
        return false
      end

      @rect.left = new_x
      try_to_fall
      return true
    end

    def update
      delta_y = update_fall_rect
      if @location.area_free?(@fall_rect) then
        @rect.top += delta_y
      else
        floor = @location.find_surface(@fall_rect)

        if floor != nil then
          @rect.top = (floor.top - @rect.h)
        end

        @location.delete_sprite self
      end
    end

    def init_images
      @image = Image.load 'bigbrick.png'
    end

    private

    def try_to_fall
      update_fall_rect
      if @location.area_free?(@fall_rect) then
        @location.add_sprite self
      end
    end

    def update_fall_rect
      delta_y = FALL_SPEED * @location.ticker.delta
      @fall_rect.h = delta_y
      @fall_rect.top = @rect.bottom
      @fall_rect.left = @rect.left + (@rect.w-@fall_rect.w)/2
      return delta_y
    end
  end
end
