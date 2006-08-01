# guardrobot.rb
# igneus 1.8.2006

# GuardRobot
# A violet mass of unfriendly metal :-).
# When he smells a viking, he tells him something bad and then he kills
# him (he has a plasma gun hidden in his both arms)

require 'monster.rb'
require 'monstermixins.rb'

module FreeVikings

  class GuardRobot < Sprite

    include Monster
    include MonsterMixins::HeroBashing
    
    WIDTH = 70
    HEIGHT = 90

    DEFAULT_GUARD_RECT = [300, HEIGHT]

    # guard_rect is a Rectangle inside of which the robot can smell vikings.
    # by default it is a Rectangle 300x90 centered on the robot's body
    def initialize(position, guard_rect=nil)
      super(position)
      @image = Model.load_new(File.open('gfx/models/guard_robot_model.xml'))
    end

    def state
      "standing"
    end
  end # class GuardRobot
end # module FreeVikings
