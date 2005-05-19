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
# igneus 4.3.2005

# Trida reprezentujici zesnuleho vikinga.

require 'sprite'

module FreeVikings

  class DeadViking < Sprite

    STATE_DURATION = 1.1
    LAST_STATE = 2

    def initialize(position)
      super(position)
      @image = ImageBank.new(self)
      im1 = Image.new('dead.png')
      im2 = Image.new('dead2.png')
      im3 = Image.new('dead3.png')
      @image.add_pair '0', im1
      @image.add_pair '1', im2
      @image.add_pair '2', im3
      @image.add_pair '3', im3

      @state = 0
      @last_update_time = Time.now.to_i
    end

    def state
      @state.to_s
    end

    def update
      # Jednou za kratky cas se zmeni stav a mozna i obrazek. Az dojdeme
      # k poslednimu stavu, mrtvola zmizi.
      if ((now = Time.now.to_i) - @last_update_time) > STATE_DURATION
	@state += 1
	@last_update_time = now
      end
      # Jestli uz mrtvola strasila dost dlouho, zmizi:
      if @state > LAST_STATE then
	@location.delete_sprite self
      end
    end
  end # class DeadViking
end # module FreeVikings
