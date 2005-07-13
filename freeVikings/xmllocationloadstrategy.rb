# xmllocationloadstrategy.rb
# igneus 29.3.2005

# Strategie nahravani map z xml datovych souboru.

require 'locationloadstrategy.rb'
require 'monsterscript.rb'
require 'map.rb'

module FreeVikings

  class XMLLocationLoadStrategy < LocationLoadStrategy

    # Mapfile muze byt String nebo IO. Je to zdroj nebo jmeno zdroje, 
    # ze ktereho bude mapa nactena.
    # Pokud druhy argument neni nastaven na nil, pred predanim zdroje XML do
    # REXML zkontroluje, zda zdroj je platnym jmenem textoveho souboru a 
    # pripadne vyhodi vyjimku.

    MIN_TILES_X = 640 / Map::TILE_SIZE
    MIN_TILES_Y = 480 / Map::TILE_SIZE

    def initialize(mapfile, data_source_control=true)
      super()

      @source = mapfile

      if data_source_control != nil then
        unless File.file? mapfile
          message = "Not such a file - #{mapfile}"
          @log.error message
          raise InvalidDataSourceException, message
        end
        @source = File.open mapfile
      end

      @doc = REXML::Document.new(@source)

      content_check
    end

    def load_map(blocks_matrix, blocktype_hash)
      @blocks = blocks_matrix
      @blocktypes = blocktype_hash

      load_tiletypes
      load_tiles
    end

    def load_scripts(location)
      @log.debug "Starting loading monsters from scripts."

      begin
	script_element = @doc.root.elements['scripts'].elements['monsters']
	scriptfile = script_element.attributes['path']
      rescue => ex
	@log.info "Cannot get the monster-script's filename from the datafile. Maybe no scripts are connected with this location. Message from the caught bottom-level exception: #{ex.message}"
	return
      end

      @log.info "Loading monsters from script #{scriptfile}"

      # Pri nahravani skriptu muze nastat velke mnozstvi vyjimecnych situaci:
      begin
        s = MonsterScript.new(scriptfile) {|script| eval "script::LOCATION = location"}
      rescue SyntaxError
        @log.error "Syntax error in the script #{scriptfile}. "
        return
      rescue NameError => ne
        @log.error "NameError in the script #{scriptfile}." \
        "(#{ne.message})"
        return
      rescue MonsterScript::NoMonstersDefinedException
        @log.error "Script loaded successfully, but didn't define any new " \
        "monsters."
      end

      s::MONSTERS.each {|m| location.add_sprite m}
      @log.info "Script #{scriptfile} successfully loaded."
    end

    def load_exit(location)
      begin
	exit_element = @doc.root.elements['map'].elements['exit']
	x = exit_element.attributes['horiz'].to_i
	y = exit_element.attributes['vertic'].to_i
      rescue
	@log.error "Cannot find XML element 'map/exit'" \
        " in datafile #{source_name}."
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
	@log.error "Cannot find XML element 'map/start' in datasource #{source_name}."
	x = y = 100
      end
      location.start = [x,y]
    end

    private

    # nahraje typy bloku

    def load_tiletypes
      begin
	@doc.root.elements['map'].elements["blocktypes"].each_element { |blocktype|
	  code = blocktype.attributes["code"]
	  path = blocktype.attributes["path"]
	  @log.debug "Loading new Tile with code '#{code}' and path '#{path}'"
	  tiletype = Tile.instance(code, path)
	  tiletype.solid = false unless blocktype.attributes["solid"] == "solid"
	  @blocktypes[code] = tiletype
	}
      rescue => ex
	@log.error "Cannot read XML node 'map/blocktypes' in datafile #{source_name}. (" + ex.message + ")"
        raise
      end
    end

    # nahraje umisteni bloku

    def load_tiles
      # nacteni umisteni bloku
      begin
	lines = @doc.root.elements["map"].elements["blocks"].text.split(/\n/)
      rescue => ex
	@log.fatal "Cannot find 'map/blocks' XML element in datafile #{source_name}. (" + ex.message + ")"
	raise
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
	    @log.error("Blocktype couldn't be found in blocktypes' hash for blockcode #{block_code} (using mapsource #{source_name})")
	  end
	}
      }
      raise LocationNotLargeEnoughException, "Location is not #{MIN_TILES_X} broad, it isn't valid and cannot be loaded." if @max_width < MIN_TILES_X
      raise LocationNotLargeEnoughException, "Location is not #{MIN_TILES_Y} high, it isn't valid and cannot be loaded." if @max_height < MIN_TILES_Y
    end

    # Vrati jmeno nacitaneho zdroje

    def source_name
      return @source if @source.is_a? String
      return @source.path if @source.is_a? File
      return @source.id.to_s
    end

    # Zkontroluje, zda zdrojovy dokument obsahuje vsechny povinne
    # elementy.

    def content_check
      begin
        raise CompulsoryElementMissingException.new('location', source_name) if @doc.root.nil? 
        raise CompulsoryElementMissingException.new('blocks', source_name) if @doc.root.elements['map'].elements['blocks'].nil?
      rescue => ex
        @log.error "Incomplete location data found in datafile #{source_name}." + "(" + ex.message + ")"
        raise
      end
    end

  end # class XMLLocationLoadStrategy



  # Vyjimka vyhazovana pri pokusu o cteni neplatneho zdroje (typicky 
  # neexistujici soubor)
  class InvalidDataSourceException < RuntimeError
  end

  # Vyjimka vyhazovana pokud datovy soubor neobsahuje vsechny povinne casti.
  class CompulsoryElementMissingException < RuntimeError

    def initialize(missing_element, file)
      @msg = "Compulsory element " + missing_element + " missing in datafile " + file + " ."
    end

    def message
      @msg
    end
  end

  # Vyjimka vyhazovana, pokud je mapa lokace prilis mala (na vysku nebo 
  # na sirku nema ani jednu obrazovku)
  class LocationNotLargeEnoughException < RuntimeError
  end
end # module FreeVikings
