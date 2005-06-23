# world.rb
# igneus 24.2.2005

# Trida World obaluje a pred svetem schovava vztahy mezi lokacemi,
# jejich nahravani a prechody.

require 'location.rb'
require 'xmllocationloadstrategy.rb'

module FreeVikings

  class World

    DATA_DIR = 'locs'
    
    def initialize(*locs)
      @location = nil
      @level = -1
      @locs = locs
      # Nastavime vychozi lokaci:
      next_location
    end

    attr_reader :location

    def next_location
      @level += 1
      if @locs[@level].nil? then
	# Zadna dalsi lokace v zasobe
	return nil
      end
      load_level
    end

    def rewind_location
      load_level
    end

    def initialised?
      @location.nil?
    end

    private
    def load_level
      strategy = XMLLocationLoadStrategy.new(DATA_DIR + '/' + @locs[@level])
      @location = Location.new(strategy)      
    end
  end # class World
end # module FreeVikings
