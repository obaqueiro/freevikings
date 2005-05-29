# warior.rb
# igneus 1.2.2005

# Podtrida tridy Viking vytvorena na miru Baleogovi.
# Valecnik umi mlatit kolem sebe mecem a strilet z luku.

require 'viking.rb'
require 'arrow.rb'
require 'sword.rb'
require 'ability.rb'

module FreeVikings
  class Warior < Viking

    def initialize(name, start_position)
      super name, start_position
      init_images
      @ability = WariorAbility.new self
      @state.ability = @ability
    end

    attr_reader :weapon

    def d_func_on
      @ability.d_on
    end

    def d_func_off
      @ability.d_off
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

      @image.add_pair('onground_standing_left', i_left)
      @image.add_pair('onground_standing_right', i_right)
      @image.add_pair('onground_moving_left', i_left)
      @image.add_pair('onground_moving_right', i_right)
      @image.add_pair('falling_standing_right', i_right)
      @image.add_pair('falling_standing_left', i_left)
      @image.add_pair('falling_moving_right', i_right)
      @image.add_pair('falling_moving_left', i_left)

      i_shootleft = Image.new('baleog_shooting_left.png')
      i_shootright = Image.new('baleog_shooting_right.png')

      @image.add_pair('onground_bow-stretching_left', i_shootleft)
      @image.add_pair('onground_bow-stretching_right', i_shootright)

      @portrait = Portrait.new 'baleog_face.tga', 'baleog_face_unactive.gif', 'dead_face.png'
    end

  end # class Warior
end #module
