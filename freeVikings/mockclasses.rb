# mockclasses.rb
# igneus 13.2.2005

# Sbirka trid uzitecnych pro testovani.

require 'maploadstrategy.rb'

module FreeVikings

  module Mock

    class TestingMapLoadStrategy < MapLoadStrategy

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
	@max_width = @max_height = 0
	# prochazime radky bloku:
	blcks.each_index { |line_num|
	  @blocks.push blcks[line_num]
	}
      end
    end # class TestingMapLoadStrategy
  end # module Mock
end # module FreeVikings
