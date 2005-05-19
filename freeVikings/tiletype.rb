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
# igneus 25.1.2005

# Trida pro typ dlazdice. Uchovava zejmena zobrazovaci a kvalitativni
# informace.

require 'imagebank'

module FreeVikings

  class TileType

    attr_accessor :solid
    alias_method :solid?, :solid

    @@instances = Hash.new

    def initialize(image_path)
      @image = Image.new(image_path)
      @solid = true
    end

    private_class_method :new

    # Pokud uz pro dany kod existuje instance, vrati ji, v opacnem pripade 
    # vytvori novou.

    def TileType.instance(code, image_path)
      unless @@instances[code].nil? then
	return @@instances[code]
      end

      @@instances[code] = new(image_path)
      return @@instances[code]
    end

    def image
      @image.image
    end
  end # class
end # module
