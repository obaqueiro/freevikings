# warior.rb
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
      @weapon = Sword.new
    end

    attr_reader :weapon

    def d_func
      @state = BowStretchingVikingState.new(self, @state)
    end

    def space_func
      @state = FightingVikingState.new self, @state

      # Nasleduje mala necistota. Musime zbrani predat odkaz na lokaci,
      # nebot mec neni registrovan jako sprajt, nybrz je jen yieldovan
      # v iteratoru each_displayable jako soucast sprajtu vikinga
      weapon.move_validator = @move_validator

      weapon.set(weapon_position, @state.direction)
    end

    def shoot
      if state.direction == "right"
	arrow_veloc = 60
      else
	arrow_veloc = -60
      end
      arrow = Arrow.new([left + 30, top + (image.h / 2) - 7], Velocity.new(arrow_veloc))
      @move_validator.add_sprite arrow
    end

    def each_displayable
      yield self
      yield weapon if @state.class == FightingVikingState
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

    def weapon_position
      weapon_pos = [nil, top + (image.h / 2)]
      if @state.direction == 'right' then
	weapon_pos[0] = left + 0.8 * image.w
      end
      if @state.direction == 'left' then
	weapon_pos[0] = left - (weapon.image.w - 0.2 * image.w)
      end
      return weapon_pos
    end

  end # class Warior
end #module
