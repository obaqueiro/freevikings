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
    include MonsterMixins::ShieldSensitive
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
      serve_shield_collision { @state.stop }
    end

    def init_images
      left = Image.load('bear_left.tga')
      anim_left = Animation.new(0.3, 
                                     [left,
                                     Image.load('bear_left_walk.tga'),
                                      left,
                                      Image.load('bear_left_walk2.tga')]
                                     )
      right = Image.load('bear_right.tga')
      anim_right = Animation.new(0.75, 
                                     [right,
                                     Image.load('bear_right_walk.tga'),
                                      right,
                                      Image.load('bear_right_walk2.tga')]
                                     )

      imgs = {
        'onground_standing_left' => Image.load('bear_left.tga'),
        'onground_standing_right' => Image.load('bear_right.tga'),
        'onground_moving_left' => anim_left,
        'onground_moving_right' => anim_right
      }
      @image = Model.new(imgs)
    end
  end # class Bear

  # WalkingBear.
  # The Bear which walks around his initial position.
  class WalkingBear < Bear

    VELOCITY = 50

    def initialize(position, max_walk_length=100)
      super(position)
      @bash_delay = 2
      @max_walk_length = max_walk_length
      @teritory_center = @rect.left + @rect.w / 2
      @walk_length = 0
      rand <= 0.5 ? move_left : move_right
      new_walk_length
    end

    def update
      @rect.left += velocity_horiz * @location.ticker.delta
      turn if on_turn_point?
      bash_heroes
      serve_shield_collision {
        if @state.direction == 'left' then
          move_right
        else
          move_left
        end

        new_walk_length
      }
    end

    private

    def new_walk_length
      @walk_length = rand * @max_walk_length
      @dest = @teritory_center + (@state.velocity_horiz * @walk_length)
    end

    def turn
      move_left if @rect.left >= @teritory_center
      move_right if @rect.left <= @teritory_center

      n = new_walk_length
          end

    def on_turn_point?
      if @state.velocity_horiz < 0 and 
          @rect.left <= @dest then
        return true
      end
      if @state.velocity_horiz > 0 and 
          @rect.left >= @dest then
        return true
      end

      return false
    end

    def velocity_horiz
      @state.velocity_horiz * BASE_VELOCITY
    end
  end # class WalkingBear

end # module FreeVikings
