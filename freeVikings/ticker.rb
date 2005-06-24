# ticker.rb
# igneus 28.6.2005

=begin
= Ticker
Ticker is a very simple synchronisation tool.
It stores a time (as a Float) and provides a method ((<Ticker#now>))
to check this time out.
When ((<Ticker#tick>)) is called to upgrade the ((<Ticker>)), the old
time is moved to another variable (you can read it through ((<Ticker#old>))) 
and a new time is stored in ((<Ticker#now>)).
=end

module FreeVikings

  class Ticker

    def initialize
      @now = @old = Time.now.to_f
      @ticks = 0
    end

=begin
--- Ticker#now
Returns the time of ((<Ticker>))'s last update.
=end

    attr_reader :now

=begin
--- Ticker#old
Returns the time ((<Ticker>)) was updated before last.
=end

    attr_reader :old

=begin
--- Ticker#ticks
Returns the count of ((<Ticker#tick>)) calls.
=end

    attr_reader :ticks

=begin
--- Ticker#tick
Updates the ((<Ticker>)).
=end

    def tick
      @ticks += 1
      @old = @now
      @now = Time.now.to_f
    end

=begin
--- Ticker#delta
Returns the difference between the ((<Ticker#now>)) and ((<Ticker#old>)) 
values.
=end

    def delta
      @now - @old
    end
  end # class Ticker
end # module FreeVikings
