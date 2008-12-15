# piranha.rb
# igneus 8.9.2008

require 'monstermixins.rb'

module FreeVikings
  
  # A deadly fish...

  class Piranha < Sprite

    VELOCITY = 10

    include MonsterMixins::HeroBashing

    # environment_rect is a Rectangle in which the fish will freely move around

    def initialize(position, environment_rect)
      super position
      @environment_rect = environment_rect
      initial_consideration
    end

    def init_images
      @image_left = Animation.new(2, [Image.load('piranha1.tga'),
                                      Image.load('piranha2.tga')])
      @image_right = Animation.new(2, [Image.load('piranha1_right.tga'),
                                      Image.load('piranha2_right.tga')])
    end

    def image
      @direction == 1 ? @image_right.image : @image_left.image
    end

    def update
      r = @rect.dup
      r.left += (VELOCITY + @location.ticker.delta) * @direction
      if @environment_rect.contains? r then
        @rect = r
      else
        @direction *= -1
      end

      # 'current_frame' of @image_left and @image_right return both the same
      bash_heroes if @image_left.current_frame == 1
    end

    private

    # Some random stuff to decide where to move

    def initial_consideration
      @direction = 0
      @direction = (1-rand(3)) while @direction == 0
      @rect.top = @environment_rect.top + rand(@environment_rect.h-@rect.h)
    end
  end
end
