# maploadstrategy.rb
# igneus 29.1.2005

# Objekty MapLoadStrategy umoznuji nacitani mapy ze souboru ruznych formatu.

require 'tiletype.rb'
require 'exit.rb'
require 'log4r'
require 'rexml/document'
require 'script'

module FreeVikings

  class LocationLoadStrategy

    # Nejdelsi delka radku v mape.
    # Inicialisovana az po zavolani load.
    attr_reader :max_width
    attr_reader :max_height

    def initialize
      @log = Log4r::Logger.new('location loading log')
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
      
      begin
	@doc = REXML::Document.new(@source)
      rescue NameError => ex
	@log.fatal "Datafile #{@source} cannot be open ( maybe it has not a valid XML syntax)."
	@log.debug "Exception message: #{ex.message}"
      end
    end

    def load_map(blocks_matrix, blocktype_hash)
      @blocks = blocks_matrix
      @blocktypes = blocktype_hash

      # nacteni typu bloku
      begin
	@doc.root.elements['map'].elements["blocktypes"].each_element { |blocktype|
	  code = blocktype.attributes["code"]
	  path = blocktype.attributes["path"]
	  @log.debug "Loading new TileType with code '#{code}' and path '#{path}'"
	  tiletype = TileType.instance(code, path)
	  tiletype.solid = false unless blocktype.attributes["solid"] == "solid"
	  @blocktypes[code] = tiletype
	}
      rescue => ex
	@log.error "Cannot read XML node 'map/blocktypes' in datafile #{@source.path}. (" + ex.message + ")"
      end

      # nacteni umisteni bloku
      begin
	lines = @doc.root.elements["map"].elements["blocks"].text.split(/\n/)
      rescue => ex
	@log.fatal "Cannot find 'map/blocks' XML element in datafile #{@source.path}. (" + ex.message + ")"
	exit 1
      end
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
      @log.debug "Starting loading monsters from scripts."

      begin
	script_element = @doc.root.elements['scripts'].elements['monsters']
	scriptfile = script_element.attributes['path']
      rescue => ex
	@log.error "Cannot load monster script."
	@log.debug "Exception message: #{ex.message}"
	return
      end
      @log.info "Loading script #{scriptfile}"
      s = Script.new scriptfile

      if s.const_defined? "MONSTERS" then
	s::MONSTERS.each {|m| monster_manager.add_sprite m.dup}
      else
	@log.info "In scriptfile #{scriptfile}: constant MONSTERS hasn't been defined. Maybe the script doesn't provide monsters."
      end
      @log.info "Script #{scriptfile} successfully loaded."
    end

    def load_exit(location)
      begin
	exit_element = @doc.root.elements['map'].elements['exit']
	x = exit_element.attributes['horiz'].to_i
	y = exit_element.attributes['vertic'].to_i
      rescue
	@log.error "Cannot find XML element 'map/exit' in datafile #{@source.path}."
	x = y = 300
      end
      location.exitter = Exit.new([x,y])
    end

    def load_start(location)
      begin
	strt_element = @doc.root.elements['map'].elements['start']
	x = strt_element.attributes['horiz'].to_i
	y = strt_element.attributes['vertic'].to_i
      rescue
	@log.error "Cannot find XML element 'map/start' in datasource #{@source.path}."
	x = y = 100
      end
      location.start = [x,y]
    end

  end # class XMLMapLoadStrategy

end # module
