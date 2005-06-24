# bear.rb
# igneus 28.6.2005

# A nice Bear which can be dangerous too.

require 'leggedspritestate.rb'

module FreeVikings

  class Bear < Sprite

    WIDTH = 60
    HEIGHT = 80

    include Monster

    def initialize(position)
      super([position[0], position[1], WIDTH, HEIGHT])
      @state = LeggedSpriteState.new
    end

    attr_reader :state

    def init_images
      anim_left = AnimationSuite.new(0.75, 
                                     [Image.new('bear_left.tga'),
                                     Image.new('bear_left_walk.tga')]
                                     )
      anim_right = AnimationSuite.new(0.75, 
                                     [Image.new('bear_right.tga'),
                                     Image.new('bear_right_walk.tga')]
                                     )

      imgs = {
        'onground_standing_left' => Image.new('bear_left.tga'),
        'onground_standing_right' => Image.new('bear_right.tga')
        'onground_moving_left' => anim_left,
        'onground_moving_right' = anim_right
      }
      @image = ImageBank.new(self, imgs)
    end
  end # class Bear
end # module FreeVikings
