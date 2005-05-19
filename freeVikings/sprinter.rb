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

# Trida na miru pro Erika. Sprinter umi rychle behat a skakat, hlavou
# muze rozbijet zdi.

module FreeVikings

  class Sprinter < Viking

    def initialize(name, start_position)
      super(name, start_position)
      init_images
    end

    def space_func
      @state = JumpingVikingState.new(self, @state)
    end

    private
    def init_images
      i_left = Image.new('erik_left.png')
      i_right = Image.new('erik_right.png')
      i_standing = Image.new('erik_standing.png')

      @image = ImageBank.new(self)

      @image.add_pair('standing_', i_standing)
      @image.add_pair('standing_left', i_left)
      @image.add_pair('standing_right', i_right)
      @image.add_pair('moving_left', i_left)
      @image.add_pair('moving_right', i_right)
      @image.add_pair('jumping', i_standing)
      @image.add_pair('stucked_', i_standing)
      @image.add_pair('stucked_left', i_left)
      @image.add_pair('stucked_right', i_right)
      @image.add_pair('falling_', i_standing)
      @image.add_pair('falling_left', i_left)
      @image.add_pair('falling_right', i_right)
      @image.add_pair('dead', Image.new('dead.png'))

      @portrait = Portrait.new 'erik_face.tga', 'erik_face_unactive.gif', 'dead_face.png'
    end
  end # class
end # module
