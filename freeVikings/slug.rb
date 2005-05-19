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
# igneus 21.2.2005

# Trida representujici roztomileho pomaleho a neskodneho trema ocima
# na stopkach opatreneho kosmickeho slimaka.

module FreeVikings

  class Slug < Sprite

    include Monster
    
    def initialize(position)
      super(position)
      init_images
    end

    def image
      @anim.image
    end

    def update
      caught = @location.sprites_on_rect(self.rect)
      caught.delete self
      unless caught.empty?
	  caught.each { |c| c.hurt if c.is_a? Hero} if (Time.now.sec % 2 == 0)
      end
    end

    private
    def init_images
      left = Image.new('slizzy_left.tga')
      right = Image.new('slizzy_right.tga')
      standing = Image.new('slizzy_standing.tga')
      @anim = AnimationSuite.new(0.4)
      @anim.add(left).add(standing).add(right).add(standing)
    end
  end # class Slug
end # module FreeVikings
