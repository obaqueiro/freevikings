# slug.rb
# igneus 21.2.2005

# Trida representujici roztomileho pomaleho a neskodneho trema ocima
# na stopkach opatreneho kosmickeho slimaka.

module FreeVikings

  class Slug < Sprite

    include Monster
    
    def initialize(position)
      super(position)
      init_images
    end

    def image
      @anim.image
    end

    def update
      caught = @move_validator.sprites_on_rect(self.rect)
      caught.delete self
      unless caught.empty?
	  caught.each { |c| c.hurt if c.is_a? Hero} if (Time.now.sec % 2 == 0)
      end
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
