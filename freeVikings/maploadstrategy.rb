# maploadstrategy.rb
# igneus 29.1.2005

# Objekty MapLoadStrategy umoznuji nacitani mapy ze souboru ruznych formatu.

require 'tiletype.rb'
require 'log4r'

module FreeVikings

  class MapLoadStrategy

    # Nejdelsi delka radku v mape.
    # Inicialisovana az po zavolani load.
    attr_reader :max_width
    attr_reader :max_height

    # Pole Blocks_matrix inicialisuje jako dvojrozmerne pole a nacte do nej
    # dlazdice ze souboru mapy.
    # Do hashe Blocktype_array ulozi objekt TileType 
    # pro kazdy typ dlazdice, ktery se v souboru mapy vyskytne.
    # Mapfile muze byt String nebo IO. Je to zdroj nebo jmeno zdroje, 
    # ze ktereho bude mapa nactena.

    def initialize(mapfile, blocks_matrix, blocktype_array)
      @blocks = blocks_matrix
      @blocktypes = blocktype_array

      @log = Log4r::Logger.new('map loading log')
      @log.level = Log4r::ERROR
      @log.outputters = Log4r::StderrOutputter.new('map loading out')

      if mapfile.is_a?(IO)
	@source = mapfile
      elsif mapfile.is_a?(String)
	@source = File.open(mapfile)
      else
	raise ArgumentError, "Argument mapfile of bad type #{mapfile.type}"
      end
    end

    # Nacte do pole bloku bloky a do pole typu jejich typy (objekty TileType)
    def load
    end

  end # class MapLoadStrategy


  class XMLMapLoadStrategy < MapLoadStrategy

    def load
      doc = REXML::Document.new(@source)
      # nacteni typu bloku
      doc.elements.each("location/blocktypes/blocktype") { |blocktype|
	code = blocktype.attributes["code"]
	path = blocktype.attributes["path"]
	if path != ""
	  @blocktypes[code] = TileType.instance(code, path)
	end
      }

      # nacteni umisteni bloku
      lines = doc.root.elements["blocks"].text.split('\n')
      @max_width = @max_height = 0
      # prochazime radky bloku:
      lines.each_index { |line_num|
	@max_height = line_num.dup if line_num > @max_height
	@blocks.push(Array.new)
	# prochazime bloky:
	line = lines[line_num]
	block_codes = line.split('\s*')
	block_codes.each_index { |block_index|
	  @max_width = block_index.dup if block_index > @max_width
	  block_code = block_codes[block_index]
	  unless @blocktypes[block_code].nil?
	    @blocks[line_num][block_index] = @blocktypes[block_code]
	    @log.debug("Setting reference to blocktype for block at index [" + line_num.to_s + "][" + block_index.to_s + "]")
	  else
	    @log.error("Blocktype couldn't be found in blocktypes' hash for blockcode #{block_code} (using mapsource #{@source})")
	  end
	}
      }
    end

  end # class XMLMapLoadStrategy

end # module
