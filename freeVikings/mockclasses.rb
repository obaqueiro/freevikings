# mockclasses.rb
# igneus 13.2.2005

# Sbirka trid uzitecnych pro testovani.

module FreeVikings

  module Mock

    class TestingMapLoadStrategy < MapLoadStrategy

      def load(blocks_matrix, blocktype_hash)
	blocktype_hash['x'] = (solid = TestingTileType.createSolid)
	blocktype_hash['o'] = (soft = TestingTileType.createSoft)
	
	blocks_matrix.push [solid, solid, solid, solid, solid]
	blocks_matrix.push [solid, soft,  soft,  soft,  solid]
	blocks_matrix.push [solid, soft,  soft,  soft,  solid]
	blocks_matrix.push [solid, soft,  soft,  soft,  solid]
	blocks_matrix.push [solid, soft,  soft,  soft,  solid]
	blocks_matrix.push [solid, soft,  soft,  soft,  solid]
	blocks_matrix.push [solid, solid, solid, solid, solid]

	@max_width = blocks_matrix[0].size
	@max_height = blocks_matrix.size
      end
    end # class TestingMapLoadStrategy

    class TestingTileType < TileType
      attr_accessor :solid
      attr_reader :image

      def initialize(solid)
	@solid = solid
	@image = RUDL::Surface.new([40,40])
      end

      def TestingTileType.createSolid
	return new(true)
      end

      def TestingTileType.createSoft
	return new(false)
      end
    end # class TestingTileType

  end # module Mock
end # module FreeVikings
