# shielder.rb
# igneus 1.2.2005

# Trida na miru pro Olafa. Shielder ma stit, umi se jim branit a plachtit
# na nem.

require 'shield.rb'

module FreeVikings

  class Shielder < Viking

    FAVOURITE_COLOUR = [190, 190, 0]

    DEFAULT_Z_VALUE = Viking::DEFAULT_Z_VALUE + 0

    SHIELD_TOP = true
    SHIELD_FRONT = false

    def initialize(name, start_position)
      super(name, start_position)
      @shield = Shield.new self
      @shield_use = SHIELD_FRONT

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

    # Must tell Shield about change of position done by a Transporter
    alias_method :_transport_move, :transport_move
    def transport_move(delta_x, delta_y, transporter)
      super(delta_x, delta_y, transporter)
      @shield.unofficial_update @location
    end

    def shield_use
      return 'top' if @shield_use == SHIELD_TOP
      return 'left' if @state.direction == 'left'
      return 'right'
    end

    def space_func_on
      @shield_use = ! @shield_use

      if @shield_use != SHIELD_TOP then
        @start_fall = @rect.top
      end
    end

    alias_method :_velocity_vertic, :velocity_vertic

    SHIELD_GLIDE_ANTIACCELERATION = 0.5

    def velocity_vertic
      if (! @state.climbing?) &&
          @shield_use == SHIELD_TOP
        return _velocity_vertic * SHIELD_GLIDE_ANTIACCELERATION
      end

      return _velocity_vertic
    end

    def init_images
      @image = Model.load_new(File.open(FreeVikings::GFX_DIR + '/models/olaf_model.xml'))

      @portrait = Portrait.new 'olaf_face.tga', 'olaf_face_unactive.gif', 'dead_face.png'
    end

    private

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
