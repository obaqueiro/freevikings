# world.rb
# igneus 24.2.2005

=begin
= World
((<World>)) instances are objects which provide three services:
* return the current (({Location})) (((<World#location>)))
* reload and return the current (({Location})) (((<World#rewind_location>)))
* load and return the next (({Location})) (((<World#next_location>)))
=end

require 'location.rb'
require 'xmllocationloadstrategy.rb'

module FreeVikings

  class World

=begin
--- World.new(*locs)
Accepts any number of arguments, which must be valid location definition files
(in XML format) from directory (({FreeVikings::DATA_DIR})).
=end
    
    def initialize(*locs)
      @location = nil
      @level = -1
      @locs = locs
      # Nastavime vychozi lokaci:
      next_location
    end

=begin
--- World#location
Returns the current (({Location})).
=end

    attr_reader :location

=begin
--- World#next_location
Loads and returns a next (({Location})).
It's used in a game when all the vikings pass a level successfully and
they can continue to another one.
=end

    def next_location
      @level += 1
      if @locs[@level].nil? then
	# Zadna dalsi lokace v zasobe
	return nil
      end
      load_level
    end

=begin
--- World#rewind_location
Reloads the current (({Location})) and returns it. It's used when the level
has to be repeated (some vikings have died or the player has given up 
the game), because playing changes the internal state of the (({Location}))
instance and so it must be loaded again.
=end

    def rewind_location
      load_level
    end

    private

    # Loads the current Location from the definition file
    def load_level
      strategy = XMLLocationLoadStrategy.new(FreeVikings::DATA_DIR + '/' + @locs[@level])
      @location = Location.new(strategy)      
    end
  end # class World
end # module FreeVikings
