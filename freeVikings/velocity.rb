# velocity.rb
# igneus 20.1.2004

module FreeVikings

  class Velocity
    # trida pro praci s rychlosti

    def initialize(velocity = 0)
      @velocity = velocity
    end

    def value
      @velocity
    end

    def value=(velocity)
      @velocity = velocity
    end
  end # class
end # module
