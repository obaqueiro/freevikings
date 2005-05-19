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
# igneus 1.2.2005

# Podtrida tridy Viking vytvorena na miru Baleogovi.
# Valecnik umi mlatit kolem sebe mecem a strilet z luku.

require 'viking.rb'
require 'arrow.rb'
require 'sword.rb'

module FreeVikings
  class Warior < Viking

    def initialize(name, start_position)
      super name, start_position
      init_images
    end

    attr_reader :weapon

    def d_func
      @state = BowStretchingVikingState.new(self, @state)
    end

    def space_func
    end

    def shoot
      if state.direction == "right"
	arrow_veloc = 60
      else
	arrow_veloc = -60
      end
      arrow = Arrow.new([left + 30, top + (image.h / 2) - 7], Velocity.new(arrow_veloc))
      @location.add_sprite arrow
    end

    private
    def init_images
      i_left = Image.new('baleog_left.png')
      i_right = Image.new('baleog_right.png')
      i_standing = Image.new('baleog_standing.png')

      @image = ImageBank.new(self)

      @image.add_pair('standing_', Image.new('baleog_standing.png'))
      @image.add_pair('standing_left', i_left)
      @image.add_pair('standing_right', i_right)
      @image.add_pair('moving_left', i_left)
      @image.add_pair('moving_right', i_right)
      @image.add_pair('stucked_left', i_left)
      @image.add_pair('stucked_right', i_right)
      @image.add_pair('falling_', i_standing)
      @image.add_pair('falling_left', i_left)
      @image.add_pair('falling_right', i_right)
      @image.add_pair('dead', Image.new('dead.png'))
      @image.add_pair('bow_stretching_left', Image.new('baleog_shooting_left.png'))
      @image.add_pair('bow_stretching_right', Image.new('baleog_shooting_right.png'))
      @image.add_pair('fighting_left', i_left)
      @image.add_pair('fighting_right', i_right)

      @portrait = Portrait.new 'baleog_face.tga', 'baleog_face_unactive.gif', 'dead_face.png'
    end

  end # class Warior
end #module
