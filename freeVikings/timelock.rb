# timelock.rb
# igneus 22.7.2005

=begin
= TimeLock
((<TimeLock>)) objects are used for a very frequent task. An instance is
initialized by a number of seconds for which it must be locked.
After this time it unlocks itself.
=end

module FreeVikings

  class TimeLock

=begin
--- TimeLock.new(seconds_to_expiry, timer)
The first argument is a number of seconds to the expiry time.
The second one is an object which provides 'now' method to get the time
information. Default is the standard Ruby built-in (({Time})) class,
but you can use e.g. a (({FreeVikings::Ticker})) instance as well.
=end

    def initialize(seconds_to_expiry=0, timer=Time)
      @timer = timer
      @seconds_to_expiry = seconds_to_expiry
      @start_time = timer.now.to_i
    end

=begin
--- TimeLock#free?
Answers the question 'is the TimeLock free yet?'.
=end

    def free?
      if time_now >= @start_time + @seconds_to_expiry then
        return true
      else
        return false
      end
    end

    private

    def time_now
      @timer.now.to_i
    end
  end # class TimeLock
end # module FreeVikings
