# sprinter.rb
# igneus 1.2.2005

# Trida na miru pro Erika. Sprinter umi rychle behat a skakat, hlavou
# muze rozbijet zdi.

module FreeVikings

  class Sprinter < Viking

    JUMP_DURATION = 1.75

    def initialize(name, start_position)
      super(name, start_position)
      init_images
      @ability = SprinterAbility.new self
      @state.ability = @ability
      @jump_start = nil
    end

    def space_func_on
      return if not on_some_surface? and not @jump_start
      @ability.space_on
    end

    def space_func_off
      @ability.space_off
      @jump_start = nil
    end

    def jump
      @state.rise
      @jump_start = @location.ticker.now unless @jump_start
    end

    alias_method :_update, :update

    def update
      _update
      if not @jump_start.nil?
        if (@location.ticker.now - @jump_start) >= JUMP_DURATION
          space_func_off
        end
      end
    end

    private
    def init_images
      i_left = Image.load('erik_left.png')
      i_right = Image.load('erik_right.png')

      @image = ImageBank.new(self)

      @image.add_pair('onground_standing_left', i_left)
      @image.add_pair('onground_standing_right', i_right)
      @image.add_pair('onground_moving_left', i_left)
      @image.add_pair('onground_moving_right', i_right)

      @image.add_pair('onground_knocked-out_left', Image.load('erik_ko_left.png'))
      @image.add_pair('onground_knocked-out_right', Image.load('erik_ko_right.png'))

      @image.add_pair('falling_standing_right', i_right)
      @image.add_pair('falling_standing_left', i_left)
      @image.add_pair('falling_moving_right', i_right)
      @image.add_pair('falling_moving_left', i_left)
      @image.add_pair('falling_jumping_left', i_left)
      @image.add_pair('falling_jumping_right', i_right)

      @image.add_pair('rising_jumping_left', i_left)
      @image.add_pair('rising_jumping_right', i_right)

      @image.add_pair('onground_jumping_left', i_left)
      @image.add_pair('onground_jumping_right', i_right)

      @portrait = Portrait.new 'erik_face.tga', 'erik_face_unactive.gif', 'dead_face.png'
    end
  end # class
end # module
