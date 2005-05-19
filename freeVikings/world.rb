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
# igneus 24.2.2005

# Trida World obaluje a pred svetem schovava vztahy mezi lokacemi,
# jejich nahravani a prechody.

require 'location.rb'
require 'locationloadstrategy.rb'

module FreeVikings

  class World

    DATA_DIR = 'locs'
    
    def initialize
      @location = nil
      @level = -1
      @locs = ['pyramida_loc.xml', 'first_loc.xml', 'hopsy_loc.xml']
      # Nastavime vychozi lokaci:
      next_location
    end

    attr_reader :location

    def next_location
      @level += 1
      if @locs[@level].nil? then
	# Zadna dalsi lokace v zasobe
	return nil
      end
      load_level
    end

    def rewind_location
      load_level
    end

    def initialised?
      @location.nil?
    end

    private
    def load_level
      strategy = XMLLocationLoadStrategy.new(DATA_DIR + '/' + @locs[@level])
      @location = Location.new(strategy)      
    end
  end # class World
end # module FreeVikings
