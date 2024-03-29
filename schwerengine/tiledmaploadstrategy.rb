# tiledmaploadstrategy.rb
# igneus 2.10.2008

module SchwerEngine

  # Loader class for loading Map from map file created
  # by Tiled (http://mapeditor.org)

  class TiledMapLoadStrategy < MapLoadStrategy

    def initialize(source)
      super(source)

      @doc = REXML::Document.new(@source)
      @tiles = {}

      @map_version = @doc.root.attributes['version']
      @log.info "Loading TilEd map version '#{@map_version}'"

      @max_width = @max_height = 0

      load
    end

    private

    def load
      load_tile_sizes
      load_tilesets
      load_properties
      load_tiles
    end

    TileSet = Struct.new(:name, :firstgid, :tile_width, :tile_height, :image, :num_tiles)

    # !!! Tilesets with different tile sizes can't be used in one map -
    # such use will lead to an error !!!

    def load_tilesets
      @log.info "Loading tilesets."

      @tilesets = []

      @doc.root.each_element('tileset') {|ts|
        name = ts.attributes['name']
        firstgid = ts.attributes['firstgid'].to_i
        tile_width = ts.attributes['tilewidth'].to_i
        tile_height = ts.attributes['tileheight'].to_i
        f = ts.elements["image"].attributes['source']
        image = RUDL::Surface.load_new @dir+"/"+f
        num_tiles = (image.w/@tile_width) * (image.h/@tile_height)

        ts = TileSet.new(name, firstgid, tile_width, tile_height, image, num_tiles)
        @log.debug("Loaded tileset '"+ts.inspect+"'")

        if ts.tile_width != @tile_width || ts.tile_height != @tile_height then
          @log.error "Tileset has wrong tile sizes! (${ts.tile_width}x${ts.tile_height} while map tile sizes are #{@tile_width}x#{@tile_height})"
          next
        end

        @tilesets.push ts
      }
    end

    # creates @blocks, @background and @foreground

    def load_tiles
      @log.info "Loading tiles."

      # try to find solid layer
      solid_layer = nil
      solid_layer_name = @properties['solid_layer']

      layers = []
      layer_names = []

      @doc.root.each_element('layer') do |layer|
        layers.push []
        layer_name = layer.attributes['name']
        layer_names.push layer_name

        layer_data = layer.elements['data']

        map_sizes = [@max_width, @max_height]

        # Read layer properties
        skip_painting = false
        layer.each_element('properties') {|ps|
          ps.each_element('property') {|p|
            case p.attributes['name']
            when 'display'
              if p.attributes['value'] == 'false' || p.attributes['value'] == 'no' then
                if layer_name != solid_layer_name then
                  @log.error "Omitting layer '#{layer_name}' from painting - attribute 'display' set to false."
                  skip_painting = true
                else
                  @log.error "Layer '#{layer_name}' must be displayed, because it's a solid layer."
                end
              end
            end
          }
        }
        next if skip_painting

        if layer_data.attributes['encoding'] then
          unless layer_data.attributes['encoding'] == 'base64'
            raise "Unsupported encoding '#{layer_data.attributes['encoding']}'.Play a bit with TilED setup to avoid layer data encoding."
          end

          Base64LayerDataLoader.new(layers.last, layer, map_sizes).load
        else
          ExpandedLayerDataLoader.new(layers.last, layer, map_sizes).load
        end
      end
      @max_height += 1

      # get data from the solid layer
      solid_layer_i = layer_names.index(solid_layer_name)
      if solid_layer_i == nil then
        @log.error "Solid layer not found. Highest layer is considered to be solid."
        solid_layer = layers.last
        solid_layer_i = layers.size - 1 # may be useful below if map property 
        #'last_background' not set
      else
        solid_layer = layers[solid_layer_i]
      end
      
      solid_layer.each do |row|
        @blocks.push []
        row.each do |tileid|
          if tileid != 0 then
            @blocks.last.push true
          else
            @blocks.last.push false
          end
        end
      end

      # find highest background surface; make just two: @background and 
      # @foreground (or just @background if @foreground isn't needed)
      # !!! @foreground has colorkey transparence, transparent colour is 
      # magenta: #ff00ff

      top_bg_layer_i = layer_names.index(@properties['last_background'])
      if top_bg_layer_i == nil then
        @log.debug "Property 'last_background' not set; map hasn't a foreground."
        top_bg_layer_i = layers.size - 1
      end

      if top_bg_layer_i >= 0 then
        @background = RUDL::Surface.new([@blocks.first.size * @tile_width,
                                         @blocks.size * @tile_height])
        @log.debug "Created background surface."
      else
        @log.debug "Background surface not created, no background layers."
      end
      if top_bg_layer_i < (layers.size - 1) then
        @foreground = RUDL::Surface.new([@blocks.first.size * @tile_width,
                                         @blocks.size * @tile_height])
        @foreground.fill([255,0,255])
        @foreground.set_colorkey([255,0,255])
        @log.debug "Created foreground surface"
      else
        @log.debug "Foreground surface not created, no foreground layers."
      end

      # paint tiles

      layers.each_with_index do |l,i|
        if i <= top_bg_layer_i then
          @log.debug "Pasting layer '#{layer_names[i]}' on background."
          s = @background 
        else
          @log.debug "Pasting layer '#{layer_names[i]}' on foreground."
          s = @foreground
        end

        l.each_with_index do |line,y|
          line.each_with_index do |tile_id,x|
            # Tiled reserves tile id 0 for 'no tile'; tile_id other than 0
            # with no tile is suspicious.
            begin
              tile = get_tile(tile_id)
            rescue NoTileException
              @log.error "No tile with id '#{tile_id}'" if tile_id != 0
              next
            end
            
            s.blit tile.surface, [x*@tile_width, y*@tile_height], tile.rect
          end
        end
      end
    end

    def load_tile_sizes
      @tile_width = @doc.root.attributes['tilewidth'].to_i
      @tile_height = @doc.root.attributes['tileheight'].to_i

      @max_width = @doc.root.attributes['width'].to_i
      @max_height = @doc.root.attributes['height'].to_i
    end

    def load_properties
      @properties = {}

      # Map format version 1.0 is slightly different then 0.99a:
      case @map_version
      when "0.99a"
        # properties are directly in the root element (map/*property)
        properties = @doc.root
      when "1.0"
        # properties are in a block element 'properties'
        # (map/properties/*property)
        properties = @doc.root.elements['properties']
      else
        @log.warn "Unknown map version '@map_version': errors may occur!"
      end

      begin
        properties.each_element('property') do |p|
          property_name = p.attributes['name']
          property_value = p.attributes['value']
          @properties[property_name] = property_value
        end
      rescue NoMethodError
        @log.warn "Map has no properties."
      end

      # This property is very important and if it isn't provided, we must
      # provide it ourselves. Let's presume that the highest layer is the solid
      # one:
      unless @properties['solid_layer']
        @properties['solid_layer'] = @doc.root.get_elements('layer').last.attributes['name']
      end
    end

    class NoTileException < RuntimeError
    end

    # surface is RUDL::Surface of tileset
    # rect is 4-element Array (part of surface which represents the tile)
    Tile = Struct.new(:surface, :rect)

    # Tries to find tile with given id (Integer) in loaded tilesets.
    # Raises TiledMapLoadStrategy::NoTileException if tile isn't found.
    # Uses Hash @tiles to store tiles which have already been found.

    def get_tile(id)
      if id == 0 then
        raise NoTileException, "Tile id 0 is reserved for Tiled and means 'no tile', 'empty space'."
      end

      if @tiles[id] then
        return @tiles[id]
      end

      tileset = @tilesets.find {|ts|
        (ts.firstgid <= id) && (ts.firstgid + ts.num_tiles > id)
      }
      if tileset == nil then
        raise NoTileException, "Tile with id '#{id}' not found in any tileset."
      end

      tile_i = id - tileset.firstgid

      columns = tileset.image.w / @tile_width
      rows = tileset.image.h / @tile_height

      tile_col = tile_i % columns
      tile_row = tile_i / columns

      tile = Tile.new(tileset.image, [tile_col*@tile_width,
                                      tile_row*@tile_height,
                                      @tile_width,
                                      @tile_height])
      @log.debug "New tile: id='#{id}', tileset='#{tileset.name}', i,c,r=#{tile_i},#{tile_col},#{tile_row}"

      @tiles[id] = tile
      return tile
    end

    # Small strategy classes. They are needed to be able to load differently
    # mutated (encoded etc.) layer data.
    # (Have I said these classes are needed to be able to load data?
    # Well, maybe. But the actual goal is to have a clean code without
    # long if-clauses and duplication).
    #
    # LayerDataLoader has two subclasses:
    # * Base64LayerDataLoader for loading Base64-encoded data
    # * ExpandedLayerDataLoader for loading unencoded data 
    #   (a huge heap of XML tags <tile gid="blah">)
    #
    # But nobody actually needs to know about LayerDataLoader unless he wants
    # to hack a bit around TilED data loading.

    class LayerDataLoader

      # blocks_matrix:: Array which will be filled with Arrays of tile ids
      # layer:: REXML::Element
      # map_size:: [width, height]
      def initialize(blocks_matrix, layer, map_size)
        @log = Log4r::Logger['location loading log']

        @blocks = blocks_matrix
        @layer = layer

        @current_row = nil

        @max_width = map_size[0]
        @max_height = map_size[1]

        unless (@max_width.is_a?(Integer) && @max_height.is_a?(Integer))
          raise ArgumentError, "Bad Array of layer sizes: [#{map_size.join(',')}]"
        end

        @tile_index = -1 # index of the last inserted tile
      end

      private

      # places a new tile into @current row, makes new @current row
      # if the current one is at the end.
      # * tile_index is index of the tile in the whole map
      # * tile_code is symbolic tile type number

      def put_tile(tile_code)
        @tile_index += 1

        if (@tile_index % @max_width) == 0 then
          @current_row = []
          @blocks.push(@current_row)
        end
        begin
          @current_row.push tile_code
        rescue RangeError => e
          @log.error "Tile with code #{tile_code} caused RangeError: "+e.message+" Once I got this error when I forgot to switch off gzip compression in Tiled!"
          raise
        end
      end
    end # class LayerDataLoader

    class Base64LayerDataLoader < LayerDataLoader
      def load
        text = @layer.elements['data'].text

        # Tile codes are encoded by Base64. The following line decodes them
        # and transforms a String of single-character codes into an Array
        # of Fixnums.
        # [Note: Decoding of Base64 is done by String#unpack.]
        data = text.strip.unpack('m')[0].split(//).collect {|s| s[0]}

        @log.debug "Loading layer '#{@layer.attributes['name']}'"

        num_tiles = data.size/4
        @log.debug "#{self.class}: Map data: '#{num_tiles}' tiles (should be #{@max_width}x#{@max_height}=#{@max_width*@max_height})"
        
        0.upto(@max_height) do |row|
          0.upto(@max_width) do |col|
            break if data.size < 4

            # This is how TilED people get tile ID from the decoded data.
            num = 0
            num = num | data.shift
            num = num | data.shift << 8
            num = num | data.shift << 16
            num = num | data.shift << 24

            put_tile num
          end
        end
      end
    end # class Base64LayerDataLoader

    class ExpandedLayerDataLoader < LayerDataLoader
      def load
        data = @layer.elements['data']
        data.each_element('tile') {|t|
          tile_number = t.attributes['gid'].to_i
          put_tile tile_number
        }
      end
    end # class ExpandedLayerDataLoader
  end
end
