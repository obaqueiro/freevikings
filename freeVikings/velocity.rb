# velocity.rb
# igneus 20.1.2004

module FreeVikings

  class Velocity
    # trida pro praci s rychlosti

    attr_accessor :acceleration

    def initialize(velocity = 0, accel=0)
      @initial_velocity = velocity
      @acceleration = accel
      @last_actualisation_time = Time.now.to_f
    end

    def value(secs_elapsed=nil)
      if @initial_velocity < 0 and @acceleration > 0 and value_now(secs_elapsed) > 0 then
	return 0
      end
      if @initial_velocity > 0 and @acceleration < 0 and value_now(secs_elapsed) < 0 then
	return 0
      end
      return value_now(secs_elapsed)
    end

    def value=(velocity)
      @initial_velocity = velocity
    end

    private
    def time_elapsed
      @last_actualisation_time = Time.now.to_f
      return @last_actualisation_time
    end

    def value_now(secs_elapsed)
      secs_elapsed = time_elapsed if secs_elapsed.nil?
      if @acceleration < 0 then
	return @initial_velocity - (@acceleration.abs * secs_elapsed)
      end
      if @acceleration > 0 then
	  return @initial_velocity + (@acceleration * secs_elapsed)
      end
      if @acceleration == 0
	return @initial_velocity
      end
    end

  end #class

end # module
