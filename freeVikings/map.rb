# map.rb
# igneus 20.1.2004

require 'tiletype'
require 'maploadstrategy'
require 'log4r'
require 'rexml/document'

module FreeVikings

  class Map
    # dlazdicova mapa

    # velikost strany dlazdice v pixelech
    TILE_SIZE = 40

    def initialize(map_path)
      @log = Log4r::Logger.new('map log')
      outputter = Log4r::StderrOutputter.new('map_stderr_output')
      @log.outputters = outputter
      @log.level = Log4r::DEBUG

      @blocktypes = Hash.new
      @blocks = Array.new
      @loading_strategy = XMLMapLoadStrategy.new(map_path, @blocks, @blocktypes)
      @background = nil

      @log.info('Loading map.')

      @loading_strategy.load

      @log.info('Map initialised.')
    end

    # vrati surface s aktualnim pozadim

    def background
      if @background.nil?
	@background = RUDL::Surface.new([@loading_strategy.max_width * TILE_SIZE, @loading_strategy.max_height * TILE_SIZE])
	
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
      
      surface.blit(background, [0,0], [left, top, left + surface.w, top + surface.h])
    end

    # nahraje mapu ze souboru
    
    private
    def load_xml_file(map_path)
      map_file = File.new(map_path)
    end # methody load_xml_file

    def get_block(coord)
      coord[0] = coord[0].to_i
      coord[1] = coord[1].to_i
      line = coord[1] / Map::TILE_SIZE
      line += 1 if (coord[1] % Map::TILE_SIZE) > 0
      column = coord[0] / Map::TILE_SIZE
      column += 1 if (coord[0] % Map::TILE_SIZE) > 0
      # Sloupkovy index je nutne pred vracenim dekrementovat, protoze
      # pri nacitani bloku se zacina az od indexu 1.
      @log.debug("get_block: I\'m going to return a reference to a blocktype of [#{line}][#{column - 1}] (tiles)")
      unless @blocks[line].is_a? Array
	@log.fatal "get_block: Line #{line} of blocks array of strange type #{@blocks[line].type}."
	raise RuntimeError, "get_block: Line #{line} of blocks array isn't an Array. (It's a #{@blocks[line].type} instance.)"
      end
      @blocks[line][column - 1]
    end

    # Vezme definici primky v podobe pole [Ax, Ay, Bx, By]  a vrati 
    # pole bloku, kterymi primka prochazi
    # Funguje spravne jen pro vodorovne a k nim kolme primky 
    # (x nebo y musi byt 0)

    public    
    def blocks_on_line(line)
      colliding_blocks = Array.new
      # inicialisace promennych iteracniho kroku:
      step_horiz = step_vertic = 0
      step_horiz = Map::TILE_SIZE if line[2] > line[0]
      step_horiz = (- Map::TILE_SIZE) if line[2] < line[0]
      step_vertic = Map::TILE_SIZE if line[3] > line[1]
      step_vertic = (- Map::TILE_SIZE) if line[3] < line[1]
      # iterovani po primce:
      carry_on = true
      horiz = line[0].round
      vertic = line[1].round
      loop do
	# ziskani bloku:
	@log.debug "block_on_line: asking for block at [#{horiz.to_s}, #{vertic.to_s}] (px)"
	begin
	  block = get_block([horiz, vertic])
	rescue RuntimeError
	  next
	end
	colliding_blocks.push(block) if block.is_a? TileType
	# nastaveni iteracnich promennych:
	horiz += step_horiz
	vertic += step_vertic
	# jestli uz jsme mimo primku, sup pryc:
	if (step_horiz > 0 and horiz > line[2]) or
	    (step_horiz < 0 and horiz < line[0]) or
	    (step_vertic > 0 and vertic > line[3]) or
	    (step_vertic < 0 and vertic < line[1]) then
	  return colliding_blocks
	end
      end
    end

    # vezme beznou definici ctverce v pixelech, vrati pole kolidujicich
    # dlazdic

    def blocks_on_square(square)
      colliding_vlocks = []
      # spocitat nejlevejsi a nejpravejsi index do kazdeho radku:
      leftmost_i = square[0] / Map::TILE_SIZE
      rightmost_i = (square[0] + square[2]) / Map::TILE_SIZE
      # spocitat prvni a posledni radek:
      top_line = square[1] / Map::TILE_SIZE
      bottom_line = (square[1] + square[3]) / Map::TILE_SIZE
      # z kazdeho radku vybrat patricny vyrez:
      @blocks[top_line .. bottom_line].each {|line|
	colliding_blocks.concat line[leftmost_i .. rightmost_i]
      }

      return colliding_blocks
    end

  end # class Map

end # modulu FreeVikings
