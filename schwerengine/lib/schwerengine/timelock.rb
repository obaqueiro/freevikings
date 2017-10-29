# timelock.rb
# igneus 22.7.2005

module SchwerEngine

  # TimeLock objects are used for a very frequent task. An instance is
  # initialized by a number of seconds for which it must be locked.
  # After this time it unlocks itself.

  class TimeLock

    # The first argument is a number of seconds to the expiry time.
    # The second one is an object which provides 'now' method to get the time
    # information. Default is the standard Ruby built-in Time class,
    # but you can use e.g. a SchwerEngine::Ticker instance as well.

    def initialize(seconds_to_expiry=0, timer=Time)
      @timer = timer
      reset(seconds_to_expiry)
    end

    # Resets timer - makes it locked again.
    # Optional argument can be used to change lock's time to expiry.

    def reset(seconds_to_expiry=nil)
      if seconds_to_expiry != nil then
        @seconds_to_expiry = seconds_to_expiry
      end
      @start_time = @timer.now.to_f
    end

    # Answers the question 'is the TimeLock free yet?'.

    def free?
      time_now >= end_time
    end

    # Returns Float saying how many seconds are left before the TimeLock
    # is free

    def time_left
      return 0.0 if free?
      return end_time - Time.now.to_f
    end

    # Returns Integer - end time (in seconds - value of timer.now.to_i 
    # at that time)

    def end_time
      return @start_time + @seconds_to_expiry
    end

    private

    def time_now
      @timer.now.to_f
    end
  end # class TimeLock
end # module SchwerEngine
