# world.rb
# igneus 24.2.2005

# Trida World obaluje a pred svetem schovava vztahy mezi lokacemi,
# jejich nahravani a prechody.

require 'location.rb'
require 'maploadstrategy.rb'

module FreeVikings

  class World
    
    def initialize
      @location = nil
    end

    attr_reader :location

    def next_location
      strategy = XMLMapLoadStrategy.new("first_loc.xml")
      @location = Location.new(strategy)
    end
  end # class World
end # module FreeVikings
