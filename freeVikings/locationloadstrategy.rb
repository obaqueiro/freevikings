# maploadstrategy.rb
# igneus 29.1.2005

# Objekty MapLoadStrategy umoznuji nacitani mapy ze souboru ruznych formatu.

require 'tiletype.rb'
require 'exit.rb'
require 'log4r'
require 'rexml/document'
require 'script'

module FreeVikings

  class LocationLoadStrategy

    # Nejdelsi delka radku v mape.
    # Inicialisovana az po zavolani load.
    attr_reader :max_width
    attr_reader :max_height

    def initialize
      @log = Log4r::Logger.new('location loading log')
      @log.outputters = Log4r::StderrOutputter.new('map loading out')
    end

    # Pole Blocks_matrix inicialisuje jako dvojrozmerne pole a nacte do nej
    # dlazdice ze souboru mapy.
    # Do hashe Blocktype_hash ulozi objekt TileType 
    # pro kazdy typ dlazdice, ktery se v souboru mapy vyskytne.
    # Nacte do pole bloku bloky a do pole typu jejich typy (objekty TileType)
    def load_map(blocks_matrix, blocktype_hash)
    end

    # Pomoci metody add_sprite rozhrani argumentu monster_manager
    # nahraje prisery
    def load_monsters(monster_manager)
    end

  end # class MapLoadStrategy

end # module
