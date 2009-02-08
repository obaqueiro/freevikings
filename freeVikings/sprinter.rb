# sprinter.rb
# igneus 1.2.2005

# Trida na miru pro Erika. Sprinter umi rychle behat a skakat, hlavou
# muze rozbijet zdi.

require 'wall.rb'

module FreeVikings

  class Sprinter < Viking

    JUMP_HEIGHT = 1.3 * Viking::HEIGHT

    FAVOURITE_COLOUR = [0,0,200]

    DEFAULT_Z_VALUE = Viking::DEFAULT_Z_VALUE + 2

    def initialize(name, start_position)
      super(name, start_position)
      @jump_start_y = nil 

      # Value of Time.now.to_f at the point viking started to walk;
      # it is used to determine whether he can run
      @walk_start_time = -1
    end

    def space_func_on
      return if not @state.on_ground?
      return if @state.knocked_out?
      return if @state.horizontal_state.is_a?(BullHeadState)

      @state.rise
      @jump_start_y = @rect.bottom unless @jump_start_y
    end

    def space_func_off
      return unless @state.rising?

      @state.fall
      @jump_start_y = nil
    end

    def d_func_on
      return unless @state.moving_horizontally?
      @state.horizontal_state = BullHeadState.new(@state)
    end

    def d_func_off
      return unless @state.horizontal_state.is_a?(BullHeadState)
      @state.stop
    end

    alias_method :_update, :update

    def update
      update_bullhead
      _update
      if not @jump_start_y.nil?
        # Nasledujici podminka ma smysl pouze ve svete, kde osa y ma nulu 
        # nahore; v normalnim svete by bylo nutne prehodit
        # mensence a mensitele v rozdilu.
        if (@jump_start_y - @rect.bottom) >= JUMP_HEIGHT
          space_func_off
        end
      end
    end

    def init_images
      @image = Model.load_new(File.open(FreeVikings::GFX_DIR+'/models/erik_model.xml'))

      @portrait = Portrait.new 'erik_face.tga', 'erik_face_unactive.gif', 'dead_face.png'
    end

    private

    def update_bullhead
      return unless @state.horizontal_state.is_a?(BullHeadState)

      @location.static_objects_on_rect(@rect).each {|o|
        if o.is_a?(Wall) then
          o.bash
          d_func_off
          break
        end
      }
    end
  end # class
end # module
