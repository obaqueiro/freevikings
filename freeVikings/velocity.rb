# velocity.rb
# igneus 20.1.2004

module FreeVikings

  class Velocity
    # trida pro praci s rychlosti

    attr_accessor :acceleration

    def initialize(velocity = 0, accel=0)
      @velocity = velocity
      @acceleration = accel
      @last_actualisation_time = Time.now.to_f
    end

    def value
      if @velocity > 0
	@velocity -= (time_delta * @acceleration)
      elsif @velocity < 0
	@velocity = - (@velocity.abs - (time_delta * @acceleration))
      end
      return @velocity
    end

    def value=(velocity)
      @velocity = velocity
    end

    private
    def time_delta
      time_now = Time.now.to_f
      delta = @last_actualisation_time - time_now
      @last_actualisation_time = time_now
      return delta
    end

  end #class

end # module
