# shielder.rb
# igneus 1.2.2005

# Trida na miru pro Olafa. Shielder ma stit, umi se jim branit a plachtit
# na nem.

require 'shield.rb'

module FreeVikings

  class Shielder < Viking

    FAVOURITE_COLOUR = [190, 190, 0]

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
      @location.add_sprite @shield
      @shield.update
    end

    def destroy
      Viking.shield = nil # remove the shield reference (shield disappeared)
      super
    end

    def update
      super
      @shield.unofficial_update
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
      if @ability.shield_use == ShielderAbility::SHIELD_TOP
        return _velocity_vertic * SHIELD_GLIDE_ANTIACCELERATION
      end
      return _velocity_vertic
    end

    private

    def init_images
      @image = Model.load_new(File.open('gfx/models/olaf_model.xml'))

      @portrait = Portrait.new 'olaf_face.tga', 'olaf_face_unactive.gif', 'dead_face.png'
    end

  end # class Shielder

end # module FreeVikings
