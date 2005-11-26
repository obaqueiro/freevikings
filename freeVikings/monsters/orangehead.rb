# orangehead.rb
# igneus 24.9.2005

# OrangeHead is a nice guy composed of a big head and two feet.
# He isn't very dangerous and doesn't kill everyone he meets.
# He is intelligent and fights only when he's attacked.

require 'sprite.rb'
require 'images.rb'
require 'monster.rb'
require 'hero.rb'
require 'timelock.rb'
require 'talkable.rb'

module FreeVikings

  class OrangeHead < Sprite

    include Monster
    include Talkable

    WIDTH = 60
    HEIGHT = 70
    SENTENCE_LASTING = 4

    # talk is a FreeVikings::Talk or nil.

    def initialize(position, talk=nil)
      super(position)
      @energy = 8
      @state = 'standing'
      @talk = talk
      @delay = TimeLock.new
    end

    attr_reader :state

    def update
      super

      if @talk then
        unless @talk.running?
          viking = @location.sprites_on_rect(@rect).find do |sprite|
            sprite.kind_of? Hero
          end

          if viking
            @talk.start(self, viking)
          end
        end

        if @talk.running? and @delay.free? then
          @talk.next
          @delay = TimeLock.new SENTENCE_LASTING
        end
      end
    end

    def init_images
      @image = Model.new(self)

      i_normal = Image.load 'heady.tga'
      i_lower = Image.load 'heady_lower.tga'

      standing_anim = Animation.new(0.4, [i_normal, i_lower])

      @image.add_pair('standing', standing_anim)
    end
  end
end # module FreeVikings
