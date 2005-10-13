# snail.rb
# igneus 13.10.2005

=begin
= NAME
Snail

= DESCRIPTION
A vociferously green snail with a violet shell.
He spits poisonous spittles.

= Superclass
Sprite
=end

require 'sprite.rb'
require 'imagebank.rb'
require 'sophisticatedspritestate.rb'
require 'sophisticatedspritemixins.rb'
require 'monster.rb'
require 'monstermixins.rb'

module FreeVikings

  class Snail < Sprite

=begin
= Included mixins
SophisticatedSpriteMixins::Walking
Monster
MonsterMixins::ShieldSensitive
=end

    include SophisticatedSpriteMixins::Walking
    include Monster
    include MonsterMixins::ShieldSensitive

    WIDTH = 90
    HEIGHT = 70

    BASE_VELOCITY = 26

    def initialize(position)
      super(position)
      @state = SophisticatedSpriteState.new
      @energy = 2
      move_right
    end

    attr_reader :state

    def update
      serve_shield_collision {stop}

      unless location.area_free?(Rectangle.new(next_left, @rect.top,
                                                  @rect.w, @rect.h))
        turn
      end

      @rect.left += velocity_horiz * @location.ticker.delta
    end

    def init_images
      i_left = Image.load 'snail_left.tga'
      i_right = Image.load 'snail_right.tga'

      @image = ImageBank.new(self, {'onground_standing_left' => i_left,
                                    'onground_moving_left' => i_left,
                                    'onground_standing_right' => i_right,
                                    'onground_moving_right' => i_right})
    end

    private

    # Turns back and starts moving.
    def turn
      if @state.right? then
        move_left
      else
        move_right
      end
    end

    def velocity_horiz
      BASE_VELOCITY * @state.velocity_horiz
    end
  end # class Snail
end # module FreeVikings
