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

    ARROW_VELOCITY = 80

    def initialize(name, start_position)
      super name, start_position
      init_images
      @ability = WariorAbility.new self
      @state.ability = @ability
      @sword = Sword.new self     
    end

    alias_method :_move_left, :move_left

    def move_left
      _move_left unless @ability.active_ability
    end

    alias_method :_move_right, :move_right

    def move_right
      _move_right unless @ability.active_ability
    end

    def d_func_on
      @ability.d_on
    end

    def d_func_off
      @ability.d_off
    end

    def space_func_on
      @ability.space_on
    end

    def space_func_off
      @ability.space_off
    end

    def release_arrow
      unless @ability.active_ability == @ability.class::D_ABILITY
        raise ReleaseArrowWithoutBowStretchingException, "The bow hasn't been stretched and it is told to release an arrow. It's an impossible mission, the world's gone mad..."
      end
      if state.direction == "right"
	arrow_veloc = ARROW_VELOCITY
      else
	arrow_veloc = - ARROW_VELOCITY
      end
      arrow = Arrow.new([left + 30, top + (image.h / 2) - 7], Velocity.new(arrow_veloc))
      @location.add_sprite arrow
    end

    # vytasi mec
    def draw_sword
      @location.add_sprite @sword
    end

    def hide_sword
      @location.delete_sprite @sword
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

      @image.add_pair('onground_sword-fighting_left', i_left)
      @image.add_pair('onground_sword-fighting_right', i_right)

      @portrait = Portrait.new 'baleog_face.tga', 'baleog_face_unactive.gif', 'dead_face.png'
    end

    # Vyjimka, ktera je vyhozena, pokud je zavolana methoda
    # release_arrow bez toho, ze by luk byl natazen
    class ReleaseArrowWithoutBowStretchingException < RuntimeError
    end

  end # class Warior
end #module
