# slug.rb
# igneus 21.2.2005

# Trida representujici roztomileho pomaleho a neskodneho trema ocima
# na stopkach opatreneho kosmickeho slimaka.

require 'hero.rb'

module FreeVikings

  class Slug < Sprite

    include Monster
    
    def initialize(position)
      super(position)
    end

    def image
      @anim.image
    end

    def update
      @rect.h = image.h
      @rect.w = image.w
      caught = @location.sprites_on_rect(self.rect)
      unless caught.empty?
	  caught.each { |c| c.hurt if c.is_a? Hero} if (Time.now.sec % 2 == 0)
      end
    end

    def init_images
      left = Image.load('slizzy_left.tga')
      right = Image.load('slizzy_right.tga')
      standing = Image.load('slizzy_standing.tga')
      @anim = AnimationSuite.new(0.4)
      @anim.add(left).add(standing).add(right).add(standing)
    end
  end # class Slug
end # module FreeVikings
