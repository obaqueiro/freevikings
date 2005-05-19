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

# Trida representujici kratky vikinsky mec

module FreeVikings

  class Sword < Sprite

    # position is an two-element array,
    # direction is 'right' or 'left'

    def initialize
      super([0,0])
      init_images
      @direction = 'right'
      @position = [0,0]
    end

    def set(position, direction)
      @position = position
      @direction = direction
    end

    def left
      @position[0]
    end

    def top
      @position[1]
    end

    def state
      @direction
    end

    def update
      stroken = @location.sprites_on_rect(self.rect)
      stroken.delete self
      unless stroken.empty?
	stroken.each do |s|
	  if s.is_a? Monster
	    s.hurt
	  end
	end
      end # unless
    end

    private
    def init_images
      left = Image.new('sword_left.png')
      right = Image.new('sword_right.png')
      @image = ImageBank.new self
      @image.add_pair 'left', left
      @image.add_pair 'right', right
    end
  end # class Sword
end # module FreeVikings
