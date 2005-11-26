# robot.rb
# igneus 9.6.2005

# Robot. Primitivni prisera, ktera chodi ze strany na stranu a 
# prilezitostne napada kolemjdouci.

require 'monster.rb'
require 'sprite.rb'
require 'monstermixins.rb'
require 'sophisticatedspritestate.rb'
require 'sophisticatedspritemixins.rb'

module FreeVikings

  class Robot < Sprite

    include Monster
    include MonsterMixins::HeroBashing
    include MonsterMixins::ShieldSensitive
    include SophisticatedSpriteMixins::Walking

    VELOCITY_NORMAL = 9
    VELOCITY_ANGRY = 50

    ANGER_DURATION = 8

    MAX_LIVES = 3

    WIDTH = 50
    HEIGHT = 80

    def initialize(position, walk_length, direction='right')
      @walk_length = walk_length
      super(position.concat([WIDTH, HEIGHT]))
      @state = RobotState.new
      @anger_start = 0
      @start_position = position
      @last_bash = 0
      @energy = MAX_LIVES
    end

    attr_reader :state

    def update
      update_position
      update_direction
      update_anger
      bash_heroes
      serve_shield_collision { stop }
    end

    alias_method :_hurt, :hurt

    def hurt
      @state.angry = true
      @anger_start = @location.ticker.now
      _hurt
    end

    def init_images
      i_right = AnimationSuite.new(1, [
                                     Image.load('robot_right.tga'),
                                     Image.load('robot_right_handdown.tga')
                                   ])
      i_left = AnimationSuite.new(1, [
                                    Image.load('robot_left.tga'),
                                    Image.load('robot_left_handdown.tga')
                                  ])

      images = {
        'onground_standing_left' => i_left,
        'onground_moving_left' => i_left,
        'onground_angry_left' => Image.load('robot_left_angry.tga'),
        'onground_standing_right' => i_right,
        'onground_moving_right' => i_right,
        'onground_angry_right' => Image.load('robot_right_angry.tga')
      }
      @image = Model.new(self, images)
    end

    private

    def update_position
      @rect.left += velocity_horiz * @location.ticker.delta
    end

    def update_direction
      if @state.direction == 'right' and @rect.left >= @start_position[0] + @walk_length then
        @state.move_left
      end
      if @state.direction == 'left' and @rect.left <= @start_position[0] then
        @state.move_right
      end
    end

    def update_anger
      if @state.angry and (@location.ticker.now >= @anger_start + ANGER_DURATION) then
        @state.angry = false
      end
    end

    def velocity_horiz
      if @state.angry then
        v = VELOCITY_ANGRY
      else
        v = VELOCITY_NORMAL
      end
      v *= @state.velocity_horiz
      return v
    end

    class RobotState < SophisticatedSpriteState
      def initialize
        super
        @angry = false
      end

      attr_accessor :angry

      def to_s
        @vertical_state.to_s + CNTR + \
        (@angry ? 'angry' : @horizontal_state.to_s) + CNTR + \
        @horizontal_state.direction
      end
    end
  end # class Robot
end # module FreeVikings
