# velocity.rb
# igneus 20.1.2004

module FreeVikings

  class Velocity
    # trida pro praci s rychlosti

    def initialize(velocity = 0)
      @initial_velocity = velocity
    end

    def value
      return @initial_velocity
    end

    def value=(velocity)
      @initial_velocity = velocity
    end
  end #class

end # module
