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
# igneus 22.2.2005

# Trida obalujici operace nad obdelnikovymi vyrezy.

module FreeVikings

  class Rectangle

    def initialize(*coordinates)
      @coordinates = coordinates[0..3]
    end

    def contains?(rect)
      if left <= rect.left and top <= rect.top and
	  right >= rect.right and bottom >= rect.bottom then
	return true
      end
      return nil
    end

    def collides?(rect)
      if self.left <= rect.right and
	  rect.left <= self.right and
	  self.top <= rect.bottom and
	  rect.top <= self.bottom then
	return true
      end
      return false
    end

    def left
      @coordinates[0]
    end

    def top
      @coordinates[1]
    end

    def w
      @coordinates[2]
    end

    def h
      @coordinates[3]
    end

    def bottom
      top + h
    end

    def right
      left + w
    end

    def to_a
      @coordinates.dup
    end

  end # class Rectangle
end # module FreeVikings
