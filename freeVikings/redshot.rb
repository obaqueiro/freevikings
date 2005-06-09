# redshot.rb
# igneus 27.2.2006

# Cervena strela do automatickych ohnometu

require 'shot.rb'

module FreeVikings

  class RedShot < Shot

    def initialize(startpos, velocity)
      super(startpos, velocity)
      @hunted_type = Hero
      @image = ImageBank.new self
      @image.add_pair 'left', Image.new('redshoot_left.tga')
      @image.add_pair 'right', Image.new('redshoot_right.tga')
    end
  end # class RedShot
end # module FreeVikings
