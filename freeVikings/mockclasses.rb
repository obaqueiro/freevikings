# mockclasses.rb
# igneus 13.2.2005

# Sbirka trid uzitecnych pro testovani.

require 'maploadstrategy.rb'

module FreeVikings

  module Mock

    class TestingMapLoadStrategy < MapLoadStrategy

      def load(blocks, blocktype_hash)
	solid = TestingTileType.createSolid
	blocktype_hash['x'] = solid
	soft  = TestingTileType.createSoft
	blocktype_hash['o'] = soft
	
	blocks.push [solid, solid, solid, solid, solid]
	blocks.push [solid, soft,  soft,  soft,  solid]
	blocks.push [solid, soft,  soft,  soft,  solid]
	blocks.push [solid, soft,  soft,  soft,  solid]
	blocks.push [solid, soft,  soft,  soft,  solid]
	blocks.push [solid, soft,  soft,  soft,  solid]
	blocks.push [solid, solid, solid, solid, solid]
      end
    end # class TestingMapLoadStrategy

    class TestingTileType < TileType
      attr_accessor :solid
      attr_reader :image

      def initialize(solid=true)
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
