# freeVikings - the "Lost Vikings" clone
# Copyright (C) 2005 Jakub "igneus" Pavlik

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
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
      @log = Log4r::Logger['location loading log']
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
