# snail.rb
# igneus 13.10.2005

# !!! FIXME:
# !!! THIS STRONGLY NEEDS TO BE SOLVED!
# !!! DOESN'T DO WHAT IT SHOULD!
# !!! I WANT THE SNAIL TO GO SOME WAY, STOP, SHOOT, WAIT UNTIL THE SHOT
# !!! IS DESTROYED AND THAN GO AGAIN. BUT IT DOESN'T DO THIS!

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
require 'shooting.rb'
require 'hero.rb'

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
    include Shooting

    WIDTH = 90
    HEIGHT = 70

    BASE_VELOCITY = 26

    SHOT_VELOCITY = 65

    GO_BETWEEN_SHOOTING = 150

    def initialize(position)
      super(position)
      @state = SophisticatedSpriteState.new
      @energy = 2
      @way_length = 0
      move_right
    end

    attr_reader :state

    def update
      serve_shield_collision {stop}

      unless location.area_free?(Rectangle.new(next_left, @rect.top,
                                                  @rect.w, @rect.h))
        turn
      end

      way_change = velocity_horiz * @location.ticker.delta
      @rect.left += way_change
      update_way way_change
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

    def update_way(way_change)
      @way_length += way_change.abs

      if @way_length >= GO_BETWEEN_SHOOTING
        @way_length = 0
        stop_and_shoot
      end
    end

    def stop_and_shoot
      @state.stop
      @last_spittle = shoot
    end

    # Turns back and starts moving.
    def turn
      puts 'turning back'
      @state.move_back
    end

    def go_on
      if @state.right? then
        move_right
      else
        move_left
      end
    end

    def shoot
      pos = velocity_horiz > 0 ? [@rect.left + WIDTH, @rect.top+10] : 
            [@rect.left - PoisonousSpittle::WIDTH, @rect.top + 10]
      veloc = velocity_horiz > 0 ? SHOT_VELOCITY : 
              -SHOT_VELOCITY
      spittle = PoisonousSpittle.new(pos, veloc)
      @location.add_sprite(spittle)
      return spittle
    end

    def velocity_horiz
      BASE_VELOCITY * @state.velocity_horiz
    end


    class PoisonousSpittle < Shot

      def initialize(position, velocity)
        super(position, velocity)
        @hunted_type = Hero
      end

      def init_images
        if @velocity < 0 then
          @image = Image.load 'snail_spittle_left.tga'
        else
          @image = Image.load 'snail_spittle_right.tga'
        end
      end
    end # class PoisonousSpittle
  end # class Snail
end # module FreeVikings
