# map.rb
# igneus 20.1.2004

require 'tiletype'
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
      @background = nil
      load_xml_file(map_path)

      @log.info('Map initialised.')
    end

    # vrati surface s aktualnim pozadim

    def background
      if @background.nil?
	@background = RUDL::Surface.new([@max_width * TILE_SIZE, @max_height * TILE_SIZE])

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

      doc = REXML::Document.new(map_file)

      # nacteni typu bloku
      doc.elements.each("location/blocktypes/blocktype") { |blocktype|
	code = blocktype.attributes["code"]
	path = blocktype.attributes["path"]
	if path != ""
	  @blocktypes[code] = TileType.instance(code, path)
	end
      }

      # nacteni umisteni bloku
      lines = doc.root.elements["blocks"].text.split('\n')
      @max_width = @max_height = 0
      # prochazime radky bloku:
      lines.each_index { |line_num|
	@max_height = line_num.dup if line_num > @max_height
	@blocks.push(Array.new)
	# prochazime bloky:
	line = lines[line_num]
	block_codes = line.split('\s*')
	block_codes.each_index { |block_index|
	  @max_width = block_index.dup if block_index > @max_width
	  block_code = block_codes[block_index]
	  unless @blocktypes[block_code].nil?
	    @blocks[line_num][block_index] = @blocktypes[block_code]
	    @log.debug("Setting reference to blocktype for block at index [" + line_num.to_s + "][" + block_index.to_s + "]")
	  else
	    @log.error("Blocktype couldn't be found in blocktypes' hash for blockcode #{block_code} (using mapfile #{map_path})")
	  end
	}
      }
    end
  end # methody load_xml_file

  def get_block(coord)
    line = coord[1] / Map::TILE_SIZE
    line += 1 if (coord[1] % Map::TILE_SIZE) > 0
    column = coord[0] / Map::TILE_SIZE
    column += 1 if (coord[0] % Map::TILE_SIZE) > 0
    # Sloupkovy index je nutne pred vracenim dekrementovat, protoze
    # pri nacitani bloku se zacina az od indexu 1.
    @blocks[line][column - 1]
  end

  # Vezme definici primky v podobe pole [Ax, Ay, Bx, By]  a vrati 
  # pole bloku, kterymi primka prochazi
  # Funguje spravne jen pro vodorovne a k nim kolme primky 
  # (x nebo y musi byt 0)

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
    horiz = line[0]
    vertic = line[1]
    loop do
      # ziskani bloku:
      block = get_block([horiz, vertic])
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

end # modulu FreeVikings
