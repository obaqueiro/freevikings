# redshot.rb
# igneus 27.2.2006

# Red shot for automatic firespitters.

require 'shot.rb'

module FreeVikings

  class RedShot < Shot

    def initialize(startpos, velocity)
      super(startpos, velocity)
      @rect.w = 15; @rect.h = 10
      @hunted_type = Hero
      @image = Model.new self
      @image.add_pair 'left', Image.load('redshoot_left.tga')
      @image.add_pair 'right', Image.load('redshoot_right.tga')
    end
  end # class RedShot
end # module FreeVikings
