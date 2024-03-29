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

    ARROW_VELOCITY = 200
    DELAY_BETWEEN_ARROWS = 1

    FAVOURITE_COLOUR = [0, 190, 0]

    DEFAULT_Z_VALUE = Viking::DEFAULT_Z_VALUE + 1

    def initialize(name, start_position)
      super name, start_position
      @sword = Sword.new self
      @last_shoot_time = 0
    end

    alias_method :_move_left, :move_left

    def move_left
      _move_left unless active_ability?
    end

    alias_method :_move_right, :move_right

    def move_right
      _move_right unless active_ability?
    end

    def d_func_on
      return if @location.ticker.now < (@last_shoot_time+DELAY_BETWEEN_ARROWS)
      return if @state.falling?

      @state.horizontal_state = BowStretchingState.new(@state)
    end

    def d_func_off
      if @state.horizontal_state.is_a?(BowStretchingState) then
        release_arrow
        @state.horizontal_state = StandingState.new(@state)
        @last_shoot_time = @location.ticker.now
      end
    end

    def space_func_on
      return if @state.falling?

      @state.horizontal_state = SwordFightingState.new(@state)
      @location.add_sprite @sword
      @sword.draw
    end

    def space_func_off
      if @state.horizontal_state.is_a? SwordFightingState then
        @state.horizontal_state = StandingState.new(@state)
        @location.delete_sprite @sword
      end
    end

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

    private

    # says if viking is fighting with sword or stretching his bow

    def active_ability?
      @state.horizontal_state.is_a?(SwordFightingState) ||
        @state.horizontal_state.is_a?(BowStretchingState)
    end

    def release_arrow
      if @state.direction == "right"
	arrow_veloc = ARROW_VELOCITY
      else
	arrow_veloc = - ARROW_VELOCITY
      end
      arrow = Arrow.new([left + 30, top + (image.h / 2) - 7], arrow_veloc)
      @location.add_sprite arrow
    end
  end # class Warior
end #module

