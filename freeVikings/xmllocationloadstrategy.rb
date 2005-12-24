# xmllocationloadstrategy.rb
# igneus 29.3.2005

# Strategie nahravani map z xml datovych souboru.

require 'rexml/document'

require 'maploadstrategy.rb'
require 'monsterscript.rb'
require 'exit.rb'

module FreeVikings

  class XMLLocationLoadStrategy < MapLoadStrategy

    MIN_TILES_X = 640 / Map::TILE_SIZE
    MIN_TILES_Y = 480 / Map::TILE_SIZE

=begin
--- XMLLocationLoadStrategy.new(source, data_source_control=true)
Argument ((|source|)) should be a (({File})) with location data.
=end

    def initialize(source)
      super(source)

      @blocktypes = {}

      @doc = REXML::Document.new(@source)

      content_check
    end

    def load(blocks_matrix)
      @blocks = blocks_matrix

      load_tiletypes
      load_tiles
    end

    private

    # nahraje typy bloku

    def load_tiletypes
      begin
        blocktypes = @doc.root.elements["blocktypes"]
        real_blocktypes = blocktypes

        if blocktypes.has_attributes? and blocktypes.attributes['src'] then
          src = get_local_file(blocktypes.attributes['src'])
          real_blocktypes = REXML::Document.new(src).root
        end

	real_blocktypes.each_element { |blocktype_element|
	  code = blocktype_element.attributes["code"]
	  path = blocktype_element.attributes["path"]
	  @log.debug "Loading new Tile with code '#{code}' and path '#{path}'"

          make_tile_solid = (blocktype_element.attributes["solid"] == "solid")

          begin
            new_blocktype = Tile.new(Image.load(path), make_tile_solid)
          rescue Image::ImageFileNotFoundException => ifnfe
            @log.error ifnfe.message
            new_blocktype = Tile.new(nil, make_tile_solid)
          end

	  @blocktypes[code] = new_blocktype
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
        text = @doc.root.elements["blocks"].text
      rescue => ex
	@log.fatal "Cannot find 'map/blocks' XML element in datafile #{source_name}. (" + ex.message + ")"
	raise
      else
        text.strip!
	lines = text.split(/\n/)
      end
      @max_width = @max_height = 0
      # prochazime radky bloku:
      lines.each_index { |line_num|
	@max_height = line_num if line_num >= @max_height

	@blocks.push(Array.new)
	# prochazime bloky:
	line = lines[line_num]
	block_codes = line.split(//)
	block_codes.each_index { |block_index|
	  @max_width = block_index + 1 if block_index >= @max_width
	  block_code = block_codes[block_index]
	  unless @blocktypes[block_code].nil?
	    @blocks[line_num][block_index] = @blocktypes[block_code]
	    # @log.debug("Setting reference to blocktype for block at index [" + line_num.to_s + "][" + block_index.to_s + "]")
	  else
	    @log.error("Blocktype couldn't be found in blocktypes' hash for blockcode #{block_code} (using mapsource #{source_name})")
	  end
	}
      }
      raise LocationNotLargeEnoughException, "Location is less then #{MIN_TILES_X} tiles broad, it isn't valid and cannot be loaded." if @max_width < MIN_TILES_X
      raise LocationNotLargeEnoughException, "Location is less then #{MIN_TILES_Y} tiles high, it isn't valid and cannot be loaded." if @max_height < MIN_TILES_Y
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
        raise CompulsoryElementMissingException.new('blocks', source_name) if @doc.root.elements['blocks'].nil?
      rescue => ex
        @log.error "Incomplete location data found in datafile #{source_name}." + "(" + ex.message + ")"
        raise
      end
    end

    # Tries to find the file with name fname in the location data directory
    # and then in the global freeVikings directory.
    # Returns a File instance. Can raise a core 'file not found' exception.

    def get_local_file(fname)
      if File.exist?(@dir+'/'+fname) then
        fname = @dir+'/'+fname
      end
      return File.open(fname)
    end

  end # class XMLLocationLoadStrategy



=begin
--- XMLLocationLoadStrategy::CompulsoryElementMissingException
Exception raised if some compulsory element misses in the data file.
=end
  class CompulsoryElementMissingException < RuntimeError

    def initialize(missing_element, file)
      @msg = "Compulsory element " + missing_element + " missing in datafile " + file + " ."
    end

    def message
      @msg
    end
  end

=begin
--- XMLLocationLoadStrategy::LocationNotLargeEnoughException
Exception raised if the loaded map is not big enough 
to fill a 640x480 px screen.
=end
  class LocationNotLargeEnoughException < RuntimeError
  end
end # module FreeVikings
