# xmlmap2loadstrategy.rb
# igneus 6.10.2008

module SchwerEngine

  # Loads old freeVikings map format (XML, human readable,
  # one tile per image file, tile size 40 px)

  class XmlMap2LoadStrategy < Map2LoadStrategy

    TILE_SIZE = 40

    # source must be acceptable argument for REXML::Document.new.
    # It must contain valid freeVikings ('old format') map data.
    # May raise XmlMap2LoadStrategy::CompulsoryElementMissingException

    def initialize(source)
      super(source)

      @tile_width = @tile_height = TILE_SIZE

      @blocktypes = {}

      @doc = REXML::Document.new(@source)

      content_check

      @blocks = []

      load_tiletypes
      load_tiles
    end

    private

    Tile = Struct.new(:image, :solid)

    # loads tile images and their codes

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

    # loads element <blocks> and creates @blocks and @background

    def load_tiles
      text = @doc.root.elements["blocks"].text
      lines = text.split(/\n/)
      lines.delete_if {|l| l =~ /^\s*$/}

      @max_height = lines.size
      @max_width = lines.first.size

      @log.debug "Map size: #{@max_width}x#{@max_height} tiles"

      @background = RUDL::Surface.new [@max_width*TILE_SIZE, 
                                       @max_height*TILE_SIZE]

      lines.each_with_index do |l, line_num|
	@blocks.push []

	line = lines[line_num]
	block_codes = line.split(//)
	block_codes.each_with_index do |b, block_index|
	  unless @blocktypes[b].nil?
	    @blocks.last.push(@blocktypes[b].solid)
	    # @log.debug("Setting reference to blocktype for block at index [" + line_num.to_s + "][" + block_index.to_s + "]")
            if @blocktypes[b].image then
              @background.blit(@blocktypes[b].image.image, 
                               [block_index*TILE_SIZE, line_num*TILE_SIZE])
            end
	  else
	    @log.error("Blocktype couldn't be found in blocktypes' hash for blockcode #{block_code} (using mapsource #{source_name})")
            @blocks.last.push false
	  end
	end
      end
    end

    # Returns file path or another identification of @source

    def source_name
      return @source if @source.is_a? String
      return @source.path if @source.is_a? File
      return @source.id.to_s
    end

    # Checks if source document contains all compulsory elements

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

    public

    # Exception raised if some compulsory element misses in the data file.
    class CompulsoryElementMissingException < ArgumentError

      def initialize(missing_element, file)
        @msg = "Compulsory element " + missing_element + " missing in datafile " + file + " ."
      end

      def message
        @msg
      end
    end
  end
end
