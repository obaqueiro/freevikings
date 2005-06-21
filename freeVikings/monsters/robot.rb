# robot.rb
# igneus 9.6.2005

# Robot. Primitivni prisera, ktera chodi ze strany na stranu a 
# prilezitostne napada kolemjdouci.

require 'monster.rb'
require 'sprite.rb'

module FreeVikings

  class Robot < Sprite

    include Monster

    VELOCITY_NORMAL = 9
    VELOCITY_ANGRY = 20

    ANGER_DURATION = 3
    BASH_DELAY = 3

    MAX_LIVES = 3

    WIDTH = 50
    HEIGHT = 80

    def initialize(position, walk_length)
      @walk_length = walk_length
      super(position.concat([WIDTH, HEIGHT]))
      @start_position = position
      @direction = 'right'
      @angry = false
      @last_update_time = time
      @last_bash = 0
      @energy = MAX_LIVES
    end

    def state
      if @angry
        return @direction + '_angry'
      else
        return @direction
      end
    end

    def update
      update_position
      update_direction
      update_anger
      bash_strange_beings
      @last_update_time = time
    end

    alias_method :_hurt, :hurt

    def hurt
      @angry = true
      _hurt
    end

    def init_images
      i_right = AnimationSuite.new(1, [
                                     Image.new('robot_right.tga'),
                                     Image.new('robot_right_handdown.tga')
                                   ])
      i_left = AnimationSuite.new(1, [
                                    Image.new('robot_left.tga'),
                                    Image.new('robot_left_handdown.tga')
                                  ])

      images = {
        'left' => i_left,
        'left_angry' => Image.new('robot_left_angry.tga'),
        'right' => i_right,
        'right_angry' => Image.new('robot_right_angry.tga')
      }
      @image = ImageBank.new(self, images)
    end

    private

    def update_position
      @rect.w = image.w
      @rect.h = image.h
      x_change = velocity * (time - @last_update_time)
      if @direction == 'right' then
        @rect.left += x_change
      else
        @rect.left -= x_change
      end
    end

    def update_direction
      if @direction == 'right' and @rect.left >= @start_position[0] + @walk_length then
        @direction = 'left'
      end
      if @direction == 'left' and @rect.left <= @start_position[0] then
        @direction = 'right'
      end
    end

    def bash_strange_beings
      return if time < @last_bash + BASH_DELAY
      @location.sprites_on_rect(@rect).each {|s|
        if s.kind_of? Hero
          s.hurt
          s.hurt if @angry # nastvany robot ublizuje dvakrat za kolo
          @last_bash = time
        end
      }
    end

    def update_anger
      if @angry and (time >= @last_update_time + ANGER_DURATION) then
        @angry = false
      end
    end

    def time
      Time.now.to_i
    end

    def velocity
      return VELOCITY_ANGRY if @angry
      VELOCITY_NORMAL
    end
  end # class Robot
end # module FreeVikings
