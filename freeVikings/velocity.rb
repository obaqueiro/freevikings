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
      if @acceleration < 0 then
	if @velocity > 0 then
	  return @velocity - (@acceleration.abs * time_elapsed)
	end
      end
      if @acceleration > 0 then
	if @velocity >= 0 then
	  return @velocity + (@acceleration * time_elapsed)
	end
      end
      if @acceleration == 0
	return @velocity
      end
    end

    def value=(velocity)
      @velocity = velocity
    end

    private
    def time_elapsed
      @last_actualisation_time = Time.now.to_f
      return @last_actualisation_time
    end

  end #class

end # module
