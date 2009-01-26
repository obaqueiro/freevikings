# exit.rb
# igneus 24.2.2005

module FreeVikings

  # Exit is a special Entity which denotes the EXIT point 
  # of the Location. The goal of the freeVikings game is to get the three
  # vikings out of several terrible places. They can escape the level only 
  # if they all stand on the EXIT point.

  class Exit < Entity

    WIDTH = 83
    HEIGHT = 99
    DEFAULT_Z_VALUE = -100

    def initialize(position)
      super position
      @image = Image.load 'exit.png'
    end

    attr_accessor :location

    # Returns true if all the living members of the Team stand
    # on the EXIT.

    def team_exited?(team)
      team.each do |member|
        unless member.alive?
          next
        end
        unless member.collision_rect.collides? @rect
          return false
        end
      end

      return true
    end
  end
end
