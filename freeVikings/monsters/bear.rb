# bear.rb
# igneus 28.6.2005

# A nice Bear which can be dangerous too.

require 'sophisticatedspritestate.rb'
require 'sophisticatedspritemixins.rb'
require 'monster.rb'
require 'monstermixins.rb'

module FreeVikings

  class Bear < Sprite

    include Monster
    include MonsterMixins::HeroBashing
    include SophisticatedSpriteMixins::Walking

    WIDTH = 60
    HEIGHT = 80
    BASE_VELOCITY = 50

    def initialize(position)
      super([position[0], position[1], WIDTH, HEIGHT])
      @state = SophisticatedSpriteState.new
    end

    attr_reader :state

    def update
      bash_heroes
      
      if stopped_by_shield? then
        puts 'Shield!'
        @state.stop
      elsif @state.standing? then
        @state.move_right
      end
    end

    def init_images
      anim_left = AnimationSuite.new(0.3, 
                                     [Image.load('bear_left.tga'),
                                     Image.load('bear_left_walk.tga')]
                                     )
      anim_right = AnimationSuite.new(0.75, 
                                     [Image.load('bear_right.tga'),
                                     Image.load('bear_right_walk.tga')]
                                     )

      imgs = {
        'onground_standing_left' => Image.load('bear_left.tga'),
        'onground_standing_right' => Image.load('bear_right.tga'),
        'onground_moving_left' => anim_left,
        'onground_moving_right' => anim_right
      }
      @image = ImageBank.new(self, imgs)
    end
  end # class Bear
end # module FreeVikings
