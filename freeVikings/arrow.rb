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
# igneus 20.2.2005

# Trida zastupujici sip

require 'shot.rb'

module FreeVikings

  class Arrow < Shot

    def initialize(start_pos, velocity)
      super start_pos, velocity
      @image = ImageBank.new(self)
      @image.add_pair('left', Image.new('arrow_left.tga'))
      @image.add_pair('right', Image.new('arrow_right.tga'))
      @hunted_type = Monster
    end
  end # class Arrow
end # module FreeVikings
