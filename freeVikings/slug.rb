# slug.rb
# igneus 21.2.2005

# Trida representujici roztomileho pomaleho a neskodneho trema ocima
# na stopkach opatreneho kosmickeho slimaka.

require 'sprite.rb'
require 'monster.rb'

module FreeVikings

  class Slug < Sprite

    include Monster
    
    def initialize
      init_images
      @top = 320
      @left = 500
    end

    def image
      @anim.image
    end

    def update
    end

    private
    def init_images
      left = Image.new('slizzy_left.tga')
      right = Image.new('slizzy_right.tga')
      standing = Image.new('slizzy_standing.tga')
      @anim = AnimationSuite.new(0.4)
      @anim.add(left).add(standing).add(right).add(standing)
    end
  end # class Slug
end # module FreeVikings
