# snail.rb
# igneus 13.10.2005

=begin
= NAME
Snail

= DESCRIPTION
A vociferously green snail with a violet shell.
Goes up and down and spits poisonous spittles.
Stops on the Shield, turns back on the wall or on the edge of a gorge which
is wide enough to let him fall down.

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
require 'timelock.rb'

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

    SHOT_VELOCITY = 65

    GO_BETWEEN_SHOOTING = 120

=begin
--- Snail.new(position)
You can see class (({Snail})) is a very comfortable to use.
The only argument needed during the initialization is the position to place
the new (({Snail})). 
So use a lot of snails anywhere :o) !
=end

    def initialize(position)
      super(position)
      @state = SophisticatedSpriteState.new
      @energy = 2
      @way_length = 0
      move_right
    end

    attr_reader :state

    def update
      if @state.moving?
        update_movement_state

        way_change = velocity_horiz * @location.ticker.delta
        @rect.left += way_change

        update_shoot(way_change)
      else
        if @spittle then
          update_spittle_waiting
        end
      end
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

    # Turns the snail if it's next position isn't free.
    # Stops if some Shield occurs in front of the snail.
    def update_movement_state
      # stop if there is a Shield
      serve_shield_collision {stop}

      # turn back if there is a wall or something solid
      unless location.area_free?(Rectangle.new(next_left, @rect.top,
                                               @rect.w, @rect.h))
        turn
      end

      # turn back if the solid ground ends in front of the snail:
      fallspace_left = @state.right? ? @rect.right : @rect.left - WIDTH
      fallspace = @rect.dup
      fallspace.left = fallspace_left
      fallspace.top += 10
      if @location.area_free? fallspace
        turn
      end
    end

    # course_delta is change of @rect.left .
    # This method stops the snail and shoots a spittle if the snail
    # has moved GO_BETWEEN_SHOOTING px.
    def update_shoot(course_delta)
      @way_length += course_delta.abs
      if @way_length >= GO_BETWEEN_SHOOTING then
        @state.stop
        @spittle = shoot
        @way_length = 0
      end
    end

    # looks if the spitted spittle has reached it's destination
    # or if it is far enough to continue going.
    def update_spittle_waiting
      if (not @spittle.alive?) or 
          ((@rect.left - @spittle.rect.left).abs >= GO_BETWEEN_SHOOTING)
        go_on
      end
    end

    # Carries on going the same direction
    def go_on
      if @state.right?
        @state.move_right
      else
        @state.move_left
      end
    end

    # Turns back and starts moving.
    def turn
      @state.move_back
    end

    # shoots a PoisonousSpittle and returns it
    def shoot
      y = @rect.top+55
      x = @state.right? ? @rect.left + WIDTH :
          @rect.left - PoisonousSpittle::WIDTH
      veloc = @state.right? ? SHOT_VELOCITY : -SHOT_VELOCITY
      spittle = PoisonousSpittle.new([x,y], veloc)
      @location.add_sprite(spittle)
      return spittle
    end

    def velocity_horiz
      BASE_VELOCITY * @state.velocity_horiz
    end

    # Class of the spittles spitted
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
