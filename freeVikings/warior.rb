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
    DELAY_BETWEEN_ARROWS = 1

    FAVOURITE_COLOUR = [0, 190, 0]

    def initialize(name, start_position)
      super name, start_position
      init_images
      @ability = WariorAbility.new self
      @state.ability = @ability
      @sword = Sword.new self
      @last_shoot_time = 0
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
      if @location.ticker.now >= (@last_shoot_time + DELAY_BETWEEN_ARROWS) then
        @ability.d_on
      end
    end

    def d_func_off
      if @ability.d_off then
        @last_shoot_time = @location.ticker.now
      end
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
      arrow = Arrow.new([left + 30, top + (image.h / 2) - 7], arrow_veloc)
      @location.add_sprite arrow
    end

    # vytasi mec
    def draw_sword
      @location.add_sprite @sword
      @sword.draw
    end

    def hide_sword
      @location.delete_sprite @sword
    end

    private
    def init_images
      @image = Model.load_new(File.open(FreeVikings::GFX_DIR + '/models/baleog_model.xml'))

      @portrait = Portrait.new 'baleog_face.tga', 'baleog_face_unactive.gif', 'dead_face.png'
    end

=begin
== ReleaseArrowWithoutBowStretchingException
Before the arrow can be released, warior's bow must be stretched.
Unless it is stretched, ((<Warior#release_arrow>)) throws this exception.
=end
    class ReleaseArrowWithoutBowStretchingException < RuntimeError
    end

  end # class Warior
end #module
 
