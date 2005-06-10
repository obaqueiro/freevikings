# arrow.rb
# igneus 20.2.2005

# Trida zastupujici sip

require 'shot.rb'
require 'monster.rb'

module FreeVikings

  WIDTH = 47
  HEIGHT = 12

  class Arrow < Shot

    def initialize(start_pos, velocity)
      super start_pos, velocity

      @rect.w = WIDTH
      @rect.h = HEIGHT

      @image = ImageBank.new(self)
      @image.add_pair('left', Image.new('arrow_left.tga'))
      @image.add_pair('right', Image.new('arrow_right.tga'))
      @hunted_type = Monster
    end
  end # class Arrow
end # module FreeVikings
