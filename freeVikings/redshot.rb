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
# igneus 27.2.2006

# Cervena strela do automatickych ohnometu

module FreeVikings

  class RedShot < Shot

    def initialize(startpos, velocity)
      super(startpos, velocity)
      @hunted_type = Hero
      @image = ImageBank.new self
      @image.add_pair 'left', Image.new('redshoot_left.tga')
      @image.add_pair 'right', Image.new('redshoot_right.tga')
    end
  end # class RedShot
end # module FreeVikings
