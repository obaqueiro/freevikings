# orangehead.rb
# igneus 24.9.2005

# OrangeHead is a nice guy composed of a big head and two feet.
# He isn't very dangerous and doesn't kill everyone he meets.
# He is intelligent and fights only when he's attacked.

require 'sprite.rb'
require 'imagebank.rb'
require 'monster.rb'
require 'hero.rb'

module FreeVikings

  class OrangeHead < Sprite

    include Monster

    WIDTH = 60
    HEIGHT = 70

    # talk is a FreeVikings::Talk or nil.

    def initialize(position, talk=nil)
      super(position)
      @energy = 8
      @state = 'standing'
      @talk = talk
    end

    attr_reader :state

    def update
      super

      if @talk then
        viking = @location.sprites_on_rect(@rect).find do |sprite|
          sprite.kind_of? Hero
        end

        if viking
          @talk.start(self, viking)
        end
      end
    end

    def init_images
      @image = ImageBank.new(self)

      i_normal = Image.load 'heady.tga'
      i_lower = Image.load 'heady_lower.tga'

      standing_anim = AnimationSuite.new(0.4, [i_normal, i_lower])

      @image.add_pair('standing', standing_anim)
    end
  end
end # module FreeVikings
