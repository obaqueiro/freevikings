# shielder.rb
# igneus 1.2.2005

# Trida na miru pro Olafa. Shielder ma stit, umi se jim branit a plachtit
# na nem.

require 'shield.rb'

module FreeVikings

  class Shielder < Viking

    FAVOURITE_COLOUR = [190, 190, 0]

    DEFAULT_Z_VALUE = Viking::DEFAULT_Z_VALUE + 0

    def initialize(name, start_position)
      super(name, start_position)
      init_images
      @ability = ShielderAbility.new self
      @state.ability = @ability
      @shield = Shield.new self

      Viking.shield = @shield # reference to the shield for all vikings
    end

    def location=(location)
      @location = location
      if @location.class == Location
        @location << @shield
      end
    end

    def destroy
      @location.delete_static_object @shield
      Viking.shield = nil # remove the shield reference (shield disappeared)
      super
    end

    def update
      super
      @shield.unofficial_update @location
      update_shield_use
    end

    def shield_use
      return 'top' if @ability.shield_use == ShielderAbility::SHIELD_TOP
      return 'left' if @state.direction == 'left'
      return 'right'
    end

    def space_func_on
      @ability.space_on

      if shield_use != 'top' then
        @start_fall = @rect.top
      end
    end

    alias_method :_velocity_vertic, :velocity_vertic

    SHIELD_GLIDE_ANTIACCELERATION = 0.5

    def velocity_vertic
      if (! @state.climbing?) &&
          @ability.shield_use == ShielderAbility::SHIELD_TOP
        return _velocity_vertic * SHIELD_GLIDE_ANTIACCELERATION
      end

      return _velocity_vertic
    end

    private

    def init_images
      @image = Model.load_new(File.open(FreeVikings::GFX_DIR + '/models/olaf_model.xml'))

      @portrait = Portrait.new 'olaf_face.tga', 'olaf_face_unactive.gif', 'dead_face.png'
    end

    # if state is such that shield cannot be used (climbing or knockout),
    # let it disappear; let it appear otherwise

    def update_shield_use
      if @state.climbing? || @state.knocked_out? then
        if Viking.shield then
          @location.delete_static_object @shield
          Viking.shield = nil
        end
      else
        if ! Viking.shield then
          @location.add_static_object @shield
          Viking.shield = @shield
        end
      end
    end

  end # class Shielder

end # module FreeVikings
