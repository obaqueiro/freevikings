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
# igneus 20.1.2004

module FreeVikings

  class Velocity
    # trida pro praci s rychlosti

    attr_accessor :acceleration

    def initialize(velocity = 0)
      @initial_velocity = velocity
    end

    def value
      return @initial_velocity
    end

    def value=(velocity)
      @initial_velocity = velocity
    end
  end #class

end # module
