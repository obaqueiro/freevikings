# guardrobot.rb
# igneus 1.8.2006

require 'monster.rb'
require 'monstermixins.rb'

module FreeVikings

  # A violet mass of unfriendly metal :-).
  # When he smells a viking, he tells him something bad and then he kills
  # him (he has a plasma gun hidden in his both arms)

  class GuardRobot < Sprite

    include Monster
    
    WIDTH = 70
    HEIGHT = 90

    # Default width and height of the guarded rectangle.
    DEFAULT_GUARD_RECT = [300, HEIGHT]

    DEFAULT_MESSAGES = {
      "warning" => "I'm gonna bash you, stranger!",
      "hurt" => "Ouch, it hurts!"
    }

    # Time between two shots in seconds
    INTERSHOT_TIME = 0.6

    # - guard_rect is a Rectangle inside of which the robot can smell vikings.
    #   by default it is a Rectangle 300x90 centered on the robot's body
    # - messages is a Hash, where keys "warning" and "hurt"
    #   are important. Values should be Strings. These are messages which the
    #   robot uses in specific situations: "warning" before he shoots, "hurt"
    #   when he is hurt.
    def initialize(position, guard_rect=nil, messages={})
      super(position)
      @image = Model.load_new(File.open('gfx/models/guard_robot_model.xml'))
      @guarded_rect = (guard_rect or compute_guarded_rect)
      @fire_timer = TimeLock.new # used to make a delay between shots
    end

    def state
      "standing"
    end

    private

    # Returns a default guarded rectangle.
    def compute_guarded_rect
      Rectangle.new((@rect.left + WIDTH/2 - DEFAULT_GUARD_RECT[0]/2),
                    (@rect.top + HEIGHT/2 - DEFAULT_GUARD_RECT[1]/2),
                    DEFAULT_GUARD_RECT[0],
                    DEFAULT_GUARD_RECT[1])
    end
  end # class GuardRobot
end # module FreeVikings
