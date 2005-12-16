# tiledlocationloadstrategy.rb
# igneus 14.12.2005

=begin
= NAME
TiledLocationLoadStrategy

= DESCRIPTION
(({LocationLoadStrategy})) which is able to load freeVikings maps 
in native format of TilED editor (they usually have suffix .tmx).

= Superclass
LocationLoadStrategy
=end

require 'rexml/document'
require 'RUDL'

require 'locationloadstrategy.rb'
require 'map.rb'

module FreeVikings

  class TiledLocationLoadStrategy < LocationLoadStrategy

    def initialize(source)
      super()

      if source.respond_to? :path then
        @dir = File.dirname(source.path)
      else
        @dir = "."
      end

      @doc = REXML::Document.new(source)
      @tiletypes = []
    end

    def load_map(blocks_matrix)
      load_map_sizes
      load_tilesets
      load_tiles blocks_matrix
    end

    def load_scripts(location)
    end

    def load_start(location)
      start = []
      @doc.root.elements['layer'].each_element('property') do |p|
        case p.attributes['name']
        when "start_x"
          start[0] = p.attributes['value'].to_i
        when "start_y"
          start[1] = p.attributes['value'].to_i
        end
      end
      location.start = start
    end

    def load_exit(location)
      place = []
      @doc.root.elements['layer'].each_element('property') do |p|
        case p.attributes['name']
        when "exit_x"
          place[0] = p.attributes['value'].to_i
        when "exit_y"
          place[1] = p.attributes['value'].to_i
        end
      end
      location.exitter = Exit.new place
    end

    private

    def load_tilesets
      @log.info "Loading tilesets."

      f = get_tileset_file

      @tiletypes = [Tile.new(nil, false)] # tile 0 is 'null tile'

      all_tiles = RUDL::Surface.load_new @dir+"/"+f

      0.step(all_tiles.h - @tile_size, @tile_size) do |y|
        0.step(all_tiles.w - @tile_size, @tile_size) do |x|
          s = RUDL::Surface.new [@tile_size, @tile_size]
          s.blit(all_tiles, [0, 0], [x, y, @tile_size, @tile_size])
          i = Image.wrap s
          @tiletypes.push Tile.new(i)
        end
      end
    end

    def load_tiles(blocks)
      @log.info "Loading tiles."

      layer_data = @doc.root.elements['layer'].elements['data']

      if layer_data.attributes['encoding'] then
        unless layer_data.attributes['encoding'] == 'base64'
          raise "Unsupported encoding #{layer_data.attributes['encoding']}. Play a bit with TilED setup to avoid layer data encoding."
        end
        text = @doc.root.elements['layer'].elements['data'].text
        Base64LayerDataLoader.new(blocks, @tiletypes, 
                                  @max_width, @max_height).load(text)
      else
        ExpandedLayerDataLoader.new(blocks, @tiletypes, 
                                    @max_width, @max_height).load(layer_data)
      end
    end

    def get_tileset_file
      @doc.root.elements['tileset'].elements["image"].attributes['source']
    end

    def load_map_sizes
      if @doc.root.attributes['tilewidth'].to_i != Map::TILE_SIZE or
          @doc.root.attributes['tileheight'].to_i != Map::TILE_SIZE then
        raise "Tile size must be #{Map::TILE_SIZE}px!"
      end
      
      @tile_size = @doc.root.attributes['tilewidth'].to_i

      @max_width = @doc.root.attributes['width'].to_i
      @max_height = @doc.root.attributes['height'].to_i
    end

=begin
--- TiledLocationLoadStrategy::LayerDataLoader
Small strategy classes. They are needed to be able to load differently
mutated (encoded etc.) layer data.
(Have I said these classes are needed to be able to load data?
Well, maybe. But the actual goal is to have a clean code without
long if-clauses and duplication).

(({LayerDataLoader})) has two subclasses:
* (({Base64LayerDataLoader})) for loading Base64-encoded data
* (({ExpandedLayerDataLoader})) for loading unencoded data 
  (a huge heap of XML tags (({<tile gid="blah">})))

But nobody actually needs to kow about (({LayerDataLoader})) unless he wants
to hack a bit around TilED data loading.
=end
    class LayerDataLoader
      def initialize(blocks_matrix, blocktypes, map_width, map_height)
        @blocks = blocks_matrix
        @blocktypes = blocktypes
        @current_row = nil
        @max_width = map_width
        @max_height = map_height
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

        @current_row.push @blocktypes[tile_code]
      end
    end # class LayerDataLoader

    class Base64LayerDataLoader < LayerDataLoader
      def load(encoded_text)
        text = encoded_text

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
      def load(data_element)
        data_element.each_element('tile') {|t|
          tile_number = t.attributes['gid'].to_i
          put_tile tile_number
        }
      end
    end # class ExpandedLayerDataLoader
  end # class TiledLocationLoadStrategy
end # module FreeVikings
