# map.rb
# igneus 20.1.2004

require 'log4r'
require 'rexml/document'

require 'tiletype.rb'
require 'group.rb'

module FreeVikings

  class Map
    # dlazdicova mapa

    # velikost strany dlazdice v pixelech
    TILE_SIZE = 40

    def initialize(map_load_strategy)
      @log = Log4r::Logger['map log']

      @blocktypes = Hash.new
      @blocks = Array.new
      loading_strategy = map_load_strategy
      @background = nil

      (@static_objects = Group.new).extend(PaintableGroup)

      @log.info('Loading map.')

      loading_strategy.load_map(@blocks, @blocktypes)

      @log.info('Map initialised.')

      @max_width = loading_strategy.max_width
      @max_height = loading_strategy.max_height

      @rect = Rectangle.new(0, 0, @max_width * TILE_SIZE, @max_height * TILE_SIZE)
    end

    attr_reader :rect
    attr_reader :static_objects

    # vrati surface s aktualnim pozadim

    def background
      unless @background
        create_background
      end
      return @background
    end # method background

    # Vykresli na surface tak velky kus mapy, jak to pujde, pricemz
    # jej vybere v okoli souradnice center_coordinate.
    # To je pole, ktere obsahuje vzdalenost odleva a shora.

    def paint(surface, center_coordinate)
      left = center_coordinate[0] - (surface.w / 2)
      top = center_coordinate[1] - (surface.h / 2)
      
      # Pozadovany stred nekde u zacatku mapy:
      left = 0 if center_coordinate[0] < (surface.w / 2)
      top = 0 if center_coordinate[1] < (surface.h / 2)
      # Pozadovany stred nekde u konce mapy:
      left = (background().w - surface.w) if center_coordinate[0] > (background().w - (surface.w / 2))
      top = (background().h - surface.h) if center_coordinate[1] > (background().h - (surface.h / 2))
      
      paint_rect = [left, top, left + surface.w, top + surface.h]
      surface.blit(background, [0,0], paint_rect)

      @static_objects.paint(surface, Rectangle.new(*paint_rect))
    end

    # vezme beznou definici ctverce v pixelech, vrati pole kolidujicich
    # dlazdic

    def blocks_on_square(square)
      @log.debug "blocks_on_square: Asked for blocks colliding with a rectangle defined by [#{square[0]}, #{square[1]}, #{square[2]}, #{square[3]}](px)"
      colliding_blocks = []
      # spocitat nejlevejsi a nejpravejsi index do kazdeho radku:
      leftmost_i = (square[0] / Map::TILE_SIZE).to_f.floor
      rightmost_i = ((square[0] + square[2]) / Map::TILE_SIZE).to_f.floor
      # spocitat prvni a posledni radek:
      top_line = (square[1] / Map::TILE_SIZE).to_f.ceil
      bottom_line = ((square[1] + square[3]) / Map::TILE_SIZE).to_f.ceil
      # z kazdeho radku vybrat patricny vyrez:
      @log.debug "blocks_on_square: I'm going to extract blocks from a square [#{leftmost_i}, #{top_line}, #{rightmost_i}, #{bottom_line}](tiles)"
      unless @blocks[top_line .. bottom_line].is_a? Array
	@log.error "blocks_on_square: Invalid lines #{top_line} .. #{bottom_line}."
	raise RuntimeError, "Invalid lines #{top_line} .. #{bottom_line}."
      end
      @blocks[top_line .. bottom_line].each {|line|
	blocks = line[leftmost_i .. rightmost_i]
	colliding_blocks.concat(blocks) if blocks.is_a? Array
      }
      return colliding_blocks
    end

    alias_method :blocks_on_rect, :blocks_on_square

    private

    # Vytvori novou RUDL::Surface @background a napatla na ni pozadi mapy
    # (obrazky vsech pevnych dlazdic)

    def create_background
      @background = RUDL::Surface.new([@rect.w, @rect.h])
	
      @blocks.each_index { |row_i|
        @blocks[row_i].each_index { |col_i|
          block_type = @blocks[row_i][col_i]
          if block_type.nil?
            @log.error("Blocktype object for block [#{row_i}][#{row_i}] wasn't found in map's internal hash.")
          end
          if block_type.is_a? TileType
            @background.blit(block_type.image, [col_i * TILE_SIZE, (row_i - 1) * TILE_SIZE])
          else
            @log.error("Found blocktype object of strange type #{block_type.type.to_s} at index [" + row_i.to_s + '][' + col_i.to_s + '] (expected TileType)')
          end
        }
      }
    end

  end # class Map

end # modulu FreeVikings
