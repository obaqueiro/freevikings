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
# igneus 27.2.2005

# Automaticky vystrelovac plazmovych strel

require 'redshot.rb'

module FreeVikings

  class PlasmaShooter < Sprite

    DELAY = 7

    def initialize(startpos, direction='left')
      super(startpos)
      @image = Image.new('spitter_1.tga')
      @last_update = Time.now.to_f
    end

    def destroy
      nil
    end

    def update
      if Time.now.to_f > @last_update + DELAY then
	@last_update = Time.now.to_f
	@location.add_sprite RedShot.new([left, top+10], Velocity.new(-55))
      end
    end
  end # class PlasmaShooter
end # module FreeVikings
