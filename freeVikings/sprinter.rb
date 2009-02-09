# sprinter.rb
# igneus 1.2.2005

require 'wall.rb'

module FreeVikings

  # Viking that can jump and bash Monsters and Walls with his magical helmet.

  class Sprinter < Viking

    JUMP_HEIGHT = 1.3 * Viking::HEIGHT

    FAVOURITE_COLOUR = [0,0,200]

    DEFAULT_Z_VALUE = Viking::DEFAULT_Z_VALUE + 2

    # maximum time (in seconds) Eric can sprint against a wall or monster
    BULL_RUN_LIMIT = 3

    def initialize(name, start_position)
      super(name, start_position)
      @jump_start_y = nil 
      @bullrun_timeout = TimeLock.new(0)
      @magical_helmet_rect = nil
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
      @bullrun_timeout.reset(BULL_RUN_LIMIT)

      # Rectangle used to find collision with Walls and Monsters;
      # exceeds @rect a bit, so crash isn't prevented by 'stop on solid object'
      # system
      ar = Rectangle.new(0,0,20,40)
      ar.top = @rect.top+20
      ar.left = if @state.direction == 'right' then
                  @rect.right
                else
                  @rect.left-ar.w
                end
      @magical_helmet_rect = RelativeRectangle.new2(@rect, ar)
    end

    def d_func_off
      return unless @state.horizontal_state.is_a?(BullHeadState)
      @state.stop
      @bullrun_timeout.reset(0)
    end

    alias_method :_update, :update

    def update
      if @state.horizontal_state.is_a?(BullHeadState) then
        update_bullhead
      end

      _update

      if @state.rising?
        # Condition below only makes sense in a world where y axis
        # has its zero at the top and y coordinate raises as moving down.
        if (@jump_start_y - @rect.bottom) >= JUMP_HEIGHT
          space_func_off
        end
      end

      if @state.horizontal_state.is_a?(BullHeadState) &&
          @state.falling? then
        d_func_off
        @state.move # walking instead of bull-run
      end
    end

    def init_images
      @image = Model.load_new(File.open(FreeVikings::GFX_DIR+'/models/erik_model.xml'))

      @portrait = Portrait.new 'erik_face.tga', 'erik_face_unactive.gif', 'dead_face.png'
    end

    private

    # called in every update when Eric is using his magical helmet

    def update_bullhead
      # viking stopped
      unless @state.moving_horizontally? then
        d_func_off
        return
      end
      # time out
      if @bullrun_timeout.free? then
        d_func_off
        @state.move
        return
      end

      # bash Walls
      @location.static_objects_on_rect(@magical_helmet_rect) do |o|
        if o.is_a?(Wall) then
          o.bash
          d_func_off
          bull_crash
          return
        end
      end

      unless @location.area_free?(@magical_helmet_rect)
        bull_crash
        return
      end

      # bash Monsters
      @location.sprites_on_rect(@magical_helmet_rect) do |o|
        if o.is_a?(Monster) then
          o.hurt
          d_func_off
          bull_crash
          return
        end
      end
    end

    # called when Eric hits something (Monster, Wall or something solid)
    # with his magical helmet

    def bull_crash
      knockout
    end
  end # class
end # module
