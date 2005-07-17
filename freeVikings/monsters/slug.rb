# slug.rb
# igneus 21.2.2005

# Trida representujici roztomileho pomaleho a neskodneho trema ocima
# na stopkach opatreneho kosmickeho slimaka.

require 'hero.rb'
require 'timelock.rb'

module FreeVikings

  class Slug < Sprite

    include Monster

    ATTACK_DELAY = 1.7
    
    def initialize(position)
      super(position)
      @attack_lock = TimeLock.new # keeps the delay between attacks
    end

    def image
      @anim.image
    end

    def update
      @rect.h = image.h
      @rect.w = image.w

      if @attack_lock.free? then
        caught = @location.sprites_on_rect(self.rect)
        caught.each do |c| 
          if c.is_a? Hero then
            c.hurt 
            @attack_lock = TimeLock.new ATTACK_DELAY
          end
        end
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
