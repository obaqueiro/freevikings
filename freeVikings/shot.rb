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
# igneus 26.2.2005

# Trida Shot (strela) je supertridou pro vsechny primocare hubici sprajty.

require 'sprite.rb'

module FreeVikings

  class Shot < Sprite

    def initialize(start_pos, velocity)
      super(start_pos)
      @velocity = velocity
      @start_time = Time.now.to_f
      @hunted_type = Sprite
    end

    def left
      @position[0] + @velocity.value * (Time.now.to_f - @start_time)
    end

    def destroy
      @velocity = Velocity.new
    end

    def state
      return "right" if @velocity.value > 0
      return "left"
    end

    def update
      unless @location.is_position_valid?(self, [left, top])
	@location.delete_sprite self
	return
      end

      stroken = @location.sprites_on_rect(self.rect)
      stroken.delete self
      unless stroken.empty?
	s = stroken.pop
	if s.is_a? @hunted_type
	  s.hurt
	  @location.delete_sprite self
	end
      end
    end

  end # class Shot
end # module FreeVikings
