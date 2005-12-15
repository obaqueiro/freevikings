# locationloadstrategy.rb
# igneus 29.1.2005

=begin
= NAME
LocationLoadStrategy

= DESCRIPTION
(({LocationLoadStrategy})) is an abstract superclass of classes which are 
used to load location contents from different kinds of sources and source
formates.

= Superclass
Object
=end

require 'exit.rb'

module FreeVikings

  class LocationLoadStrategy

    DEFAULT_START_POINT = [5,5]
    DEFAULT_EXIT_POINT  = [100,100]

=begin
--- LocationLoadStrategy#max_width
--- LocationLoadStrategy#max_height
=end

    attr_reader :max_width
    attr_reader :max_height

    def initialize
      @log = Log4r::Logger['location loading log']
    end

=begin
--- LocationLoadStrategy#load_map(blocks_matrix)
Feeds ((|blocks_matrix|)) (expected to be an (({Array}))) by (({Array}))s
of (({Tile})) instances.
=end

    def load_map(blocks_matrix)
      raise "Not implemented."
    end

=begin
--- LocationLoadStrategy#load_scripts(location)
Adds into ((|location|)) monsters and other in-game objects if any supplied
for the location being loaded.
=end

    def load_scripts(location)
    end

=begin
--- LocationLoadStrategy#load_exit(location)
Adds (({Exit})) into ((|location|)).
=end

    def load_exit(location)
      location.exitter = Exit.new(DEFAULT_EXIT_POINT)
    end

=begin
--- LocationLoadStrategy.load_start(location)
Supplies ((|location|)) information about where to place vikings 
on the beginning of game.
=end

    def load_start(location)
      location.start = DEFAULT_START_POINT
    end
  end # class MapLoadStrategy

end # module
