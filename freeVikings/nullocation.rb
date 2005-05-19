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
# igneus 7.3.2005

# Nulovy objekt pro Location

require 'location.rb'

module FreeVikings

  class NullLocation < Location

    def initialize(loader=nil)
    end

    def update
    end

    def paint(surface, center)
    end

    def background
      Image.new
    end

    def add_sprite(sprite)
    end

    attr_accessor :exitter

    def delete_sprite(sprite)
    end

    def sprites_on_rect(rect)
      []
    end

    def is_position_valid?(sprite, position)
      true
    end

  end # class NullLocation
end # module FreeVikings
