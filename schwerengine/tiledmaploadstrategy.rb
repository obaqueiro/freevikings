# tiledmaploadstrategy.rb
# igneus 2.10.2008

module SchwerEngine

  # Loader class for loading Map from map file created
  # by Tiled (http://mapeditor.org)

  class TiledMapLoadStrategy < MapLoadStrategy

    def initialize(source)
      super(source)

      @doc = REXML::Document.new(@source)
      @tiletypes = []

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

    def load_tilesets
      @log.info "Loading tilesets."

      f = get_tileset_file

      @tiletypes = [nil] # tile 0 is nil

      @tileset_image = RUDL::Surface.load_new @dir+"/"+f

      0.step(@tileset_image.h - @tile_height, @tile_height) do |y|
        0.step(@tileset_image.w - @tile_width, @tile_width) do |x|
          tile_rect = [x, y, @tile_width, @tile_height]
          @tiletypes.push tile_rect
        end
      end
    end

    # creates @blocks, @background and @foreground

    def load_tiles
      @log.info "Loading tiles."

      # first get tile ids from every layer:

      layers = []
      layer_names = []

      @doc.root.each_element('layer') do |layer|
        layers.push []
        layer_names.push layer.attributes['name']

        layer_data = layer.elements['data']

        map_sizes = [@max_width, @max_height]

        if layer_data.attributes['encoding'] then
          unless layer_data.attributes['encoding'] == 'base64'
            raise "Unsupported encoding '#{layer_data.attributes['encoding']}'.Play a bit with TilED setup to avoid layer data encoding."
          end

          Base64LayerDataLoader.new(layers.last, layer, map_sizes).load
        else
          ExpandedLayerDataLoader.new(layers.last, layer, map_sizes).load
        end

        # I don't know why, but Tiled maps have the first row of tiles invisible.
        # This is a dirty trick to make it visible - add one row of empty tiles
        layers.last.unshift( [0] * @max_width )
      end
      @max_height += 1

      # then find solid layer and fill @blocks:

      solid_layer = nil

      solid_layer_i = layer_names.index(@properties['solid_layer'])

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
            if @tiletypes[tile_id] == nil then
              @log.error "No tile with id '#{tile_id}'" if tile_id != 0
              next
            end
            
            s.blit @tileset_image, [x*@tile_width, y*@tile_height], @tiletypes[tile_id]
          end
        end
      end
    end

    def get_tileset_file
      @doc.root.elements['tileset'].elements["image"].attributes['source']
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
