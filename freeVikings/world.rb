# world.rb
# igneus 24.2.2005

# Trida World obaluje a pred svetem schovava vztahy mezi lokacemi,
# jejich nahravani a prechody.

require 'location.rb'
require 'locationloadstrategy.rb'

module FreeVikings

  class World
    
    def initialize
      @location = nil
    end

    attr_reader :location

    def next_location
      strategy = XMLLocationLoadStrategy.new("first_loc.xml")
      @location = Location.new(strategy)
    end

    def rewind_location
      # zatim je tu svindl:
      next_location
    end
  end # class World
end # module FreeVikings
