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
        @path = File.dirname(source.path)
      else
        @path = "."
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

    private

    def load_tilesets
      @log.info "Loading tilesets."

      f = get_tileset_file

      @tiletypes = []

      all_tiles = RUDL::Surface.load_new @path+"/"+f

      0.step(all_tiles.w - @tile_size, @tile_size) do |x|
        0.step(all_tiles.h - @tile_size, @tile_size) do |y|
          s = RUDL::Surface.new [@tile_size, @tile_size]
          s.blit(all_tiles, [0, 0], [x, y, @tile_size, @tile_size])
          i = Image.wrap s
          @tiletypes.push Tile.new(i)
        end
      end
    end

    def load_tiles(blocks)
      @log.info "Loading tiles."

      text = @doc.root.elements['layer'].elements['data'].text

      # Tile codes are encoded by Base64. The following line decodes them
      # and transforms a String of single-character codes into an Array
      # of Fixnums.
      # [Note: Decoding of Base64 is done by String#unpack.]
      data = text.strip.unpack('m')[0].split(//).collect {|s| s[0]}

      current_row = nil

      data.each_index do |i|
        if (i % @max_width) == 0 then
          current_row = []
          blocks.push(current_row)
        end

        current_row.push @tiletypes[data[i]]
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
  end # class TiledLocationLoadStrategy
end # module FreeVikings
