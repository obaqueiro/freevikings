# tiledmaploadstrategy.rb
# igneus 14.12.2005

=begin
= NAME
TiledMapLoadStrategy

= DESCRIPTION
(({LocationLoadStrategy})) which is able to load freeVikings maps 
in native format of TilED editor (they usually have suffix .tmx).

= Superclass
MapLoadStrategy
=end

require 'rexml/document'
require 'RUDL'

module FreeVikings

  class TiledMapLoadStrategy < MapLoadStrategy

    def initialize(source)
      super(source)

      @doc = REXML::Document.new(@source)
      @tiletypes = []
    end

    def load(blocks_matrix)
      load_map_sizes
      load_properties
      load_tilesets
      load_tiles blocks_matrix
    end

    private

    def load_tilesets
      @log.info "Loading tilesets."

      f = get_tileset_file

      @tiletypes = [Tile.new(nil, false)] # tile 0 is 'null tile'

      tileset_image = RUDL::Surface.load_new @dir+"/"+f

      0.step(tileset_image.h - @tile_size, @tile_size) do |y|
        0.step(tileset_image.w - @tile_size, @tile_size) do |x|
          s = RUDL::Surface.new [@tile_size, @tile_size]
          s.blit(tileset_image, [0, 0], [x, y, @tile_size, @tile_size])
          i = Image.wrap s
          @tiletypes.push Tile.new(i, false)
        end
      end
    end

    def load_tiles(blocks)
      @log.info "Loading tiles."


      @doc.root.each_element('layer') do |layer|
        layer_data = layer.elements['data']
        if layer_data.attributes['encoding'] then
          unless layer_data.attributes['encoding'] == 'base64'
            raise "Unsupported encoding '#{layer_data.attributes['encoding']}'.Play a bit with TilED setup to avoid layer data encoding."
          end

          Base64LayerDataLoader.new(blocks, @tiletypes, 
                                    layer, @properties).load
        else
          ExpandedLayerDataLoader.new(blocks, @tiletypes,
                                      layer, @properties).load
        end
      end
    end

    def get_tileset_file
      @doc.root.elements['tileset'].elements["image"].attributes['source']
    end

    def load_map_sizes
      if @doc.root.attributes['tilewidth'].to_i != Map::TILE_SIZE or
          @doc.root.attributes['tileheight'].to_i != Map::TILE_SIZE then
        raise "Tile size must be #{Map::TILE_SIZE}x#{Map::TILE_SIZE}px!"
      end
      
      @tile_size = @doc.root.attributes['tilewidth'].to_i

      @max_width = @doc.root.attributes['width'].to_i
      @max_height = @doc.root.attributes['height'].to_i
    end

    def load_properties
      @properties = {}

      @doc.root.each_element('property') do |p|
        property_name = p.attributes['name']
        property_value = p.attributes['value']
        @properties[property_name] = property_value
      end

      # Properties are also used as data packets given to the DataLoaders.
      # Let's add some more essential map characteristics:
      @properties['map_width'] = @max_width
      @properties['map_height'] = @max_height

      # This property is very important and if it isn't provided, we must
      # provide it ourselves. Let's presume that the highest layer is the solid
      # one:
      unless @properties['solid_layer']
        @properties['solid_layer'] = @doc.root.get_elements('layer').last.attributes['name']
      end
    end

=begin
--- TiledMapLoadStrategy::LayerDataLoader
Small strategy classes. They are needed to be able to load differently
mutated (encoded etc.) layer data.
(Have I said these classes are needed to be able to load data?
Well, maybe. But the actual goal is to have a clean code without
long if-clauses and duplication).

(({LayerDataLoader})) has two subclasses:
* (({Base64LayerDataLoader})) for loading Base64-encoded data
* (({ExpandedLayerDataLoader})) for loading unencoded data 
  (a huge heap of XML tags (({<tile gid="blah">})))

But nobody actually needs to know about (({LayerDataLoader})) unless he wants
to hack a bit around TilED data loading.
=end
    class LayerDataLoader
      def initialize(blocks_matrix, blocktypes, layer, map_properties)
        @log = Log4r::Logger['location loading log']

        @blocks = blocks_matrix
        @blocktypes = blocktypes
        @layer = layer

        @current_row = nil

        @map_properties = map_properties

        @max_width = map_properties['map_width'].to_i
        @max_height = map_properties['map_height'].to_i
        @tile_index = -1 # index of the last inserted tile

        # flag which says if matrix @blocks contains any tiles from past
        # (it would mean we are loading second, third, or ... layer)
        @blocks_prefilled = blocks_matrix.empty? ? false : true

        if @map_properties['solid_layer'] == @layer.attributes['name'] then
          @log.debug "Solid layer #{@map_properties['solid_layer']}"
          # create solid tiles and add them into @blocktypes:
          @blocktypes = [@blocktypes[0]].concat(@blocktypes[1..@blocktypes.size-1].collect {|tile| tile.to_solid })
        end
      end

      private

      # places a new tile into @current row, makes new @current row
      # if the current one is at the end.
      # * tile_index is index of the tile in the whole map
      # * tile_code is symbolic tile type number

      def put_tile(tile_code)
        @tile_index += 1

        if @blocks_prefilled then
          row = @tile_index / @max_width
          col = @tile_index % @max_width
          tile = @blocktypes[tile_code]
          unless tile.empty?
            if @blocks[row][col].solid? then
              tile = tile.to_solid
            end
            @blocks[row][col] = tile
          end
        else
          if (@tile_index % @max_width) == 0 then
            @current_row = []
            @blocks.push(@current_row)
          end
          begin
            @current_row.push @blocktypes[tile_code]
          rescue RangeError => e
            @log.error "Tile with code #{tile_code} caused RangeError: "+e.message+" Once I got this error when I forgot to switch off gzip compression in Tiled!"
            raise
          end
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
  end # class TiledMapLoadStrategy
end # module FreeVikings
