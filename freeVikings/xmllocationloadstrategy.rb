# xmllocationloadstrategy.rb
# igneus 29.3.2005

# Strategie nahravani map z xml datovych souboru.

require 'locationloadstrategy.rb'
require 'monsterscript.rb'

module FreeVikings

  class XMLLocationLoadStrategy < LocationLoadStrategy

    # Mapfile muze byt String nebo IO. Je to zdroj nebo jmeno zdroje, 
    # ze ktereho bude mapa nactena.
    # Pokud druhy argument neni nastaven na nil, pred predanim zdroje XML do
    # REXML zkontroluje, zda zdroj je platnym jmenem textoveho souboru a 
    # pripadne vyhodi vyjimku.

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
      s = MonsterScript.new scriptfile
      s::MONSTERS.each {|m| monster_manager.add_sprite m}
      @log.info "Script #{scriptfile} successfully loaded."
    end

    def load_exit(location)
      begin
	exit_element = @doc.root.elements['map'].elements['exit']
	x = exit_element.attributes['horiz'].to_i
	y = exit_element.attributes['vertic'].to_i
      rescue
	@log.error "Cannot find XML element 'map/exit' in datafile #{source_name}."
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
	  @log.debug "Loading new TileType with code '#{code}' and path '#{path}'"
	  tiletype = TileType.instance(code, path)
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

end # module FreeVikings
