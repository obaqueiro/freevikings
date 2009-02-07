# bear.rb
# igneus 28.6.2005

# A nice Bear which can be dangerous too.

require 'monstermixins.rb'

module FreeVikings

  # WalkingBear.
  # The Bear which walks around his initial position.
  class WalkingBear < Sprite

    include Monster
    include MonsterMixins::HeroBashing
    include MonsterMixins::ShieldSensitive

    WIDTH = 60
    HEIGHT = 80
    BASE_VELOCITY = 50

    def initialize(position, max_walk_length=100)
      super(position)
      @bash_delay = 2
      @max_walk_length = max_walk_length
      @teritory_center = @rect.left + @rect.w / 2
      @walk_length = 0
      @direction = (rand <= 0.5) ? -1 : 1
      new_walk_length
    end

    attr_reader :state

    def image
      if moving_left? then
        return @anim_left.image
      else
        return @anim_right.image
      end
    end

    def update
      @rect.left += velocity_horiz * @location.ticker.delta

      bash_heroes

      if on_turn_point? || stopped_by_shield? then
        turn
        new_walk_length
      end
    end

    private

    def new_walk_length
      @walk_length = rand * @max_walk_length
      @dest = @teritory_center + (@direction * @walk_length)
    end

    def moving_left?
      @direction < 0
    end

    def moving_right?
      @direction > 0
    end

    def turn
      @direction *= -1
    end

    def on_turn_point?
      if moving_left? and 
          @rect.left <= @dest then
        return true
      end
      if moving_right? and 
          @rect.left >= @dest then
        return true
      end

      return false
    end

    def velocity_horiz
      @direction * BASE_VELOCITY
    end

    public

    def init_images
      right = Image.load('bear_right.tga')
      left = Image.load('bear_left.tga')


      @anim_left = Animation.new(0.3, 
                                     [left,
                                     Image.load('bear_left_walk.tga'),
                                      left,
                                      Image.load('bear_left_walk2.tga')]
                                     )

      @anim_right = Animation.new(0.75, 
                                     [right,
                                     Image.load('bear_right_walk.tga'),
                                      right,
                                      Image.load('bear_right_walk2.tga')]
                                     )
    end

  end # class WalkingBear

end # module FreeVikings
