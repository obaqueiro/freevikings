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
      @level = 0
      @locs = ['first_loc.xml', 'hopsy_loc.xml']
      # Nastavime vychozi lokaci:
      next_location
    end

    attr_reader :location

    def next_location
      if @locs[@level].nil? then
	# Zadna dalsi lokace v zasobe
	return nil
      end
      strategy = XMLLocationLoadStrategy.new(@locs[@level])
      @level += 1
      @location = Location.new(strategy)
    end

    def rewind_location
      # zatim je tu svindl:
      next_location
    end

    def initialised?
      @location.nil?
    end
  end # class World
end # module FreeVikings
