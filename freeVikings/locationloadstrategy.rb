# maploadstrategy.rb
# igneus 29.1.2005

# Objekty MapLoadStrategy umoznuji nacitani mapy ze souboru ruznych formatu.

require 'tiletype.rb'
require 'exit.rb'
require 'log4r'

module FreeVikings

  class LocationLoadStrategy

    # Nejdelsi delka radku v mape.
    # Inicialisovana az po zavolani load.
    attr_reader :max_width
    attr_reader :max_height

    def initialize
      @log = Log4r::Logger.new('map loading log')
      @log.outputters = Log4r::StderrOutputter.new('map loading out')
    end

    # Pole Blocks_matrix inicialisuje jako dvojrozmerne pole a nacte do nej
    # dlazdice ze souboru mapy.
    # Do hashe Blocktype_hash ulozi objekt TileType 
    # pro kazdy typ dlazdice, ktery se v souboru mapy vyskytne.
    # Nacte do pole bloku bloky a do pole typu jejich typy (objekty TileType)
    def load_map(blocks_matrix, blocktype_hash)
    end

    # Pomoci metody add_sprite rozhrani argumentu monster_manager
    # nahraje prisery
    def load_monsters(monster_manager)
    end

  end # class MapLoadStrategy


  class XMLLocationLoadStrategy < LocationLoadStrategy

    # Mapfile muze byt String nebo IO. Je to zdroj nebo jmeno zdroje, 
    # ze ktereho bude mapa nactena.

    def initialize(mapfile)
      super()

      @log.level = Log4r::ERROR

      if mapfile.is_a?(IO)
	@source = mapfile
      elsif mapfile.is_a?(String)
	@source = File.open(mapfile)
      else
	raise ArgumentError, "Argument mapfile of bad type #{mapfile.type}"
      end

      @doc = REXML::Document.new(@source)
    end

    def load_map(blocks_matrix, blocktype_hash)
      @blocks = blocks_matrix
      @blocktypes = blocktype_hash

      # nacteni typu bloku
      @doc.elements.each("location/blocktypes/blocktype") { |blocktype|
	code = blocktype.attributes["code"]
	path = blocktype.attributes["path"]
	tiletype = TileType.instance(code, path)
	tiletype.solid = false unless blocktype.attributes["solid"] == "solid"
	@blocktypes[code] = tiletype
      }

      # nacteni umisteni bloku
      lines = @doc.root.elements["blocks"].text.split(/\n/)
      @max_width = @max_height = 0
      # prochazime radky bloku:
      lines.each_index { |line_num|
	@max_height = line_num if line_num > @max_height
	@blocks.push(Array.new)
	# prochazime bloky:
	line = lines[line_num]
	block_codes = line.split(/\s*/)
	block_codes.each_index { |block_index|
	  @max_width = block_index if block_index > @max_width
	  block_code = block_codes[block_index]
	  unless @blocktypes[block_code].nil?
	    @blocks[line_num][block_index] = @blocktypes[block_code]
	    @log.debug("Setting reference to blocktype for block at index [" + line_num.to_s + "][" + block_index.to_s + "]")
	  else
	    @log.error("Blocktype couldn't be found in blocktypes' hash for blockcode #{block_code} (using mapsource #{@source.is_a?(File) ? @source.path : @source})")
	  end
	}
      }
    end

    def load_monsters(monster_manager)
      duck = Duck.new
      slizzy = Slug.new
      spittie = PlasmaShooter.new([1000, 350])

      monster_manager.add_sprite slizzy
      monster_manager.add_sprite duck
      monster_manager.add_sprite spittie
    end

    def load_exit(location)
      @doc.root.elements.each('exit') { |exit_element|
	x = exit_element.attributes['horiz'].to_i
	y = exit_element.attributes['vertic'].to_i
	location.exitter = Exit.new([x,y])
      }
    end

    def load_start(location)
      strt_element = @doc.root.elements['start']
      x = strt_element.attributes['horiz'].to_i
      y = strt_element.attributes['vertic'].to_i
      location.start = [x,y]
    end

  end # class XMLMapLoadStrategy

end # module
