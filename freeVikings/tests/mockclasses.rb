# mockclasses.rb
# igneus 13.2.2005

# Collection of mock classes which are useful for unit testing.

require 'locationloadstrategy.rb'

module FreeVikings

  module Mock

    # A location loading Strategy (for Location tests).
    # It doesn't parse any XML files => the tests are quicker.
    class TestingMapLoadStrategy < LocationLoadStrategy

      def load_map(blocks_matrix, blocktype_hash)
	@blocks = blocks_matrix
	@blocktypes = blocktype_hash

	# nacteni typu bloku
	x = @blocktypes['x'] = TileType.instance('x', '')
	@blocktypes['x'].solid = true
	o = @blocktypes['o'] = TileType.instance('o', '')
	@blocktypes['o'].solid = false
	# nacteni umisteni bloku
	blcks = [
	  [x, x, o, o, o, o, o, x],
	  [x, x, o, o, o, o, o, x],
	  [x, x, o, o, o, o, o, x],
	  [x, x, o, o, o, o, o, x],
	  [x, x, o, o, o, o, o, x],
	  [x, x, o, o, o, o, o, x],
	  [x, x, o, o, o, o, o, x],
	  [x, x, x, x, x, x, x, x]
	]
	@max_width = blcks[0].size
        @max_height = blcks.size
	# prochazime radky bloku:
	blcks.each_index { |line_num|
	  @blocks.push blcks[line_num]
	}
      end

      def load_exit(location)
      end

      def load_start(location)
      end
    end # class TestingMapLoadStrategy

    # A corrupted class MockLocation.
    # A mock location has no internal mechanism, it just stores
    # the data we want her to return from method calls.
    class MockLocation
      def initialize
        @position_validator_proc = Proc.new {|sprite, position| true}
        @sprites_on_rect = []
        @sprites = []
      end

      attr_accessor :sprites
      attr_writer :sprites_on_rect
      attr_accessor :position_validator_proc

      def add_sprite(sprite)
        @sprites << sprite
        sprite.location = self
      end

      def delete_sprite(sprite)
        @sprites.delete sprite
      end
      
      def is_position_valid?(sprite, position)
        return @position_validator_proc.call(sprite, position)
      end

      def sprites_on_rect(rect)
        @sprites_on_rect.dup
      end
    end

  end # module Mock
end # module FreeVikings
